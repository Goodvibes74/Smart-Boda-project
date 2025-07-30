#include <Wire.h>
#include <HardwareSerial.h> // Now explicitly used for Serial1 and Serial2
#include <TinyGPS++.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>

#include <time.h> // Include for time manipulation functions

#define FSR_PIN 35
#define GPS_RX_PIN 34 // Connect GPS TX to ESP32 RX (GPIO34)
#define GPS_TX_PIN 32 // Connect GPS RX to ESP32 TX (GPIO32)

// SIM800L HardwareSerial Pins (Adjust these based on your ESP32 wiring)
#define SIM_RX_PIN 26 // Connect SIM800L TX to ESP32 RX (GPIO26)
#define SIM_TX_PIN 27 // Connect SIM800L RX to ESP32 TX (GPIO27)

// Emergency Contact Number (REPLACE WITH ACTUAL PHONE NUMBER)
const char* EMERGENCY_PHONE_NUMBER = "0766192699"; // e.g., "+1234567890"

// Function Declarations
String getGPSISO8601Time();
void detectAndUploadCrash(); // Renamed to reflect general crash handling
void sendSMS(String phoneNumber, String message);

// Use HardwareSerial for GPS and SIM800L
// Serial1 and Serial2 are available on ESP32. Serial0 is typically for USB/debugging.
HardwareSerial gpsSerial(1); // Use UART1 for GPS
HardwareSerial sim800lSerial(2); // Use UART2 for SIM800L

TinyGPSPlus gps;
Adafruit_MPU6050 mpu;

// Global variables for crash detection state
bool potentialCrash = false;
unsigned long potentialCrashStartTime = 0;
// Increased duration threshold to filter out transient spikes, typical crashes last longer.
const unsigned long CRASH_DURATION_THRESHOLD_MS = 100; // Increased from 10ms to 100ms

// Constants for crash detection thresholds
// FSR: Assuming lower value means more pressure/impact. Calibrate this value based on your specific FSR and setup.
const int FSR_CRASH_THRESHOLD = 2000; // FSR reading greater than 2000 triggers the algorithm.

// Acceleration (G-force) thresholds for severity (1-5)
const float ACCEL_SEVERITY_1_G = 6.0; // Minimum G-force for severity 1
const float ACCEL_SEVERITY_2_G = 7.0;
const float ACCEL_SEVERITY_3_G = 8.0;
const float ACCEL_SEVERITY_4_G = 9.0;
const float ACCEL_SEVERITY_5_G = 10.0; // G-force for severity 5 (very severe)

// Gyroscope (angular velocity) thresholds for crash type (spin detection)
// These thresholds apply to the magnitude of rotation around individual axes.
const float GYRO_TYPE_MINOR_DEG_PER_SEC = 50.0;   // Minimum angular velocity for a specific spin type

// Speed threshold for algorithm trigger (10 m/s = 36 km/h)
const float SPEED_CRASH_THRESHOLD_KMPH = 36.0; // 10 m/s converted to km/h

const int TIME_ZONE_OFFSET_SECONDS = 3 * 3600; // EAT is UTC+3 hours

#ifndef PI
#define PI 3.14159265358979323846
#endif

/**
 * @brief Sends an SMS message using the SIM800L module.
 * @param phoneNumber The recipient's phone number (e.g., "+2567xxxxxxxx").
 * @param message The text message to send.
 */
void sendSMS(String phoneNumber, String message) {
    Serial.println("Attempting to send SMS...");
    sim800lSerial.print("AT+CMGF=1\r\n"); // Set SMS to text mode
    delay(100);
    sim800lSerial.print("AT+CMGS=\"");
    sim800lSerial.print(phoneNumber);
    sim800lSerial.print("\"\r\n");
    delay(100);
    sim800lSerial.print(message);
    delay(100);
    sim800lSerial.write((char)26); // End of SMS message (CTRL+Z)
    delay(2000); // Give SIM800L time to send

    // Read response from SIM800L
    while (sim800lSerial.available()) {
        Serial.write(sim800lSerial.read());
    }
    Serial.println("SMS send command initiated. Check Serial for SIM800L response.");
}

/**
 * @brief Gets the current time from the GPS module, adjusts for local time zone,
 * and formats it into a simplified ISO 8601-like string (YYYY-MM-DD-HH-MM-SS).
 * @return A String representing the formatted current time, or an error placeholder.
 */
String getGPSISO8601Time() {
    // Check if both date and time are valid from the GPS module
    if (gps.date.isValid() && gps.time.isValid()) {
        struct tm ptm = {0}; // Initialize to all zeros
        // Populate the tm struct from GPS data (which is UTC)
        ptm.tm_year = gps.date.year() - 1900;
        ptm.tm_mon = gps.date.month() - 1;
        ptm.tm_mday = gps.date.day();
        ptm.tm_hour = gps.time.hour();
        ptm.tm_min = gps.time.minute();
        ptm.tm_sec = gps.time.second();

        // Convert tm struct to Unix epoch time (seconds since 1970)
        time_t epochTime = mktime(&ptm);
        
        // Add the time zone offset in seconds
        epochTime += TIME_ZONE_OFFSET_SECONDS;

        // Convert the adjusted epoch time back to a tm struct for formatting
        struct tm *ptm_local = localtime(&epochTime);
        
        char formattedTime[20]; // YYYY-MM-DD-HH-MM-SS\0
        sprintf(formattedTime, "%04d-%02d-%02d-%02d-%02d-%02d",
                ptm_local->tm_year + 1900,
                ptm_local->tm_mon + 1,
                ptm_local->tm_mday,
                ptm_local->tm_hour,
                ptm_local->tm_min,
                ptm_local->tm_sec);
        
        return String(formattedTime);
    } else {
        // If GPS time is not yet valid, use a placeholder
        return "GPS-Time-Not-Ready";
    }
}

void detectAndUploadCrash() { // Function name remains, but now it sends SMS
    // 1. Read Sensor Data
    sensors_event_t a, g, temp;
    mpu.getEvent(&a, &g, &temp);

    // Calculate total acceleration in G's
    float totalAcceleration_mps2 = sqrt(pow(a.acceleration.x, 2) + pow(a.acceleration.y, 2) + pow(a.acceleration.z, 2));
    float totalAcceleration_g = totalAcceleration_mps2 / 9.80665; // Convert m/s^2 to G's

    // Calculate total angular velocity in degrees/second (magnitude of 3D vector)
    float totalAngularVelocity_radps = sqrt(pow(g.gyro.x, 2) + pow(g.gyro.y, 2) + pow(g.gyro.z, 2));
    float totalAngularVelocity_degps = totalAngularVelocity_radps * (180.0 / PI); // Convert rad/s to deg/s

    // Read FSR value
    int fsrValue = analogRead(FSR_PIN);

    // Process GPS data
    while (gpsSerial.available() > 0) {
        gps.encode(gpsSerial.read());
    }
    double latitude = gps.location.isValid() ? gps.location.lat() : 0.0;
    double longitude = gps.location.isValid() ? gps.location.lng() : 0.0;
    double speed_kmph = gps.speed.isValid() ? gps.speed.kmph() : 0.0;

    // 2. Determine Algorithm Trigger Conditions
    // Algorithm is triggered if speed is greater than 10 m/s (36 km/h) OR FSR reads less than 500
    bool speedOrFSRTriggered = (speed_kmph >= SPEED_CRASH_THRESHOLD_KMPH || fsrValue > FSR_CRASH_THRESHOLD);

    // Determine if there's any significant sensor activity (impact or rotation)
    // This acts as a filter to ensure the trigger isn't from minor bumps without actual impact/rotation.
    bool significantImpact = (totalAcceleration_g >= ACCEL_SEVERITY_1_G);
    bool significantRotation = (totalAngularVelocity_degps >= GYRO_TYPE_MINOR_DEG_PER_SEC);

    // A potential crash needs to meet the primary trigger AND have significant sensor activity
    bool conditionsMet = speedOrFSRTriggered && (significantImpact || significantRotation);

    // 3. Manage Potential Crash State
    if (conditionsMet) {
        if (!potentialCrash) {
            // First time conditions are met, start the timer
            potentialCrash = true;
            potentialCrashStartTime = millis();
            Serial.println("Potential crash conditions met. Starting timer...");
        } else {
            // Conditions are still met, check if duration threshold is reached
            if (millis() - potentialCrashStartTime >= CRASH_DURATION_THRESHOLD_MS) {
                // CRASH CONFIRMED!
                Serial.println("CRASH DETECTED!");
                Serial.println("FSR: " + String(fsrValue));
                Serial.println("Accel (G): " + String(totalAcceleration_g));
                Serial.println("Gyro (deg/s): " + String(totalAngularVelocity_degps));
                Serial.println("Latitude: " + String(latitude, 6));
                Serial.println("Longitude: " + String(longitude, 6));
                Serial.println("Speed (km/h): " + String(speed_kmph, 2));

                // 4. Categorize Crash Severity (based on G-force, 1-5 scale)
                int severity = 0;
                if (totalAcceleration_g >= ACCEL_SEVERITY_5_G) {
                    severity = 5;
                } else if (totalAcceleration_g >= ACCEL_SEVERITY_4_G) {
                    severity = 4;
                } else if (totalAcceleration_g >= ACCEL_SEVERITY_3_G) {
                    severity = 3;
                } else if (totalAcceleration_g >= ACCEL_SEVERITY_2_G) {
                    severity = 2;
                } else if (totalAcceleration_g >= ACCEL_SEVERITY_1_G) {
                    severity = 1;
                }
                
                // 5. Determine Crash Type (based on angular velocity axis/polarity, or stationary hit)
                String crashType = "Unclassified Impact"; // Default type if none of the specific types match

                // Stationary Hit: Speed below 36kmph AND FSR below 500 AND there's actual acceleration (impact)
                if (speed_kmph < SPEED_CRASH_THRESHOLD_KMPH && fsrValue < FSR_CRASH_THRESHOLD && significantImpact) {
                    crashType = "Stationary Hit";
                }
                // If not a Stationary Hit, check for Rotational Spins if there's significant rotation
                else if (significantRotation) {
                    // Assuming MPU is mounted such that:
                    // +X = Roll Right, -X = Roll Left
                    // +Y = Pitch Down (Forward Spin), -Y = Pitch Up (Backward Spin)
                    // Z is the axis of forward travel, so rotation around Z is Yaw (not a requested specific type)
                    // You might need to adjust the polarity (positive/negative sign) based on your MPU's physical orientation.

                    float absGyroX = abs(g.gyro.x);
                    float absGyroY = abs(g.gyro.y);
                    float absGyroZ = abs(g.gyro.z);

                    // Prioritize dominant rotation (Pitch or Roll) for classification
                    if (absGyroY >= absGyroX && absGyroY >= absGyroZ && absGyroY >= GYRO_TYPE_MINOR_DEG_PER_SEC) {
                        // Dominant is Y-axis (Pitch)
                        if (g.gyro.y > 0) {
                            crashType = "Forward Spin"; // Positive Y-gyro for forward pitch (e.g., nose dipping)
                        } else {
                            crashType = "Backward Spin"; // Negative Y-gyro for backward pitch (e.g., nose lifting)
                        }
                    } else if (absGyroX >= absGyroY && absGyroX >= absGyroZ && absGyroX >= GYRO_TYPE_MINOR_DEG_PER_SEC) {
                        // Dominant is X-axis (Roll)
                        if (g.gyro.x > 0) {
                            crashType = "Right Spin"; // Positive X-gyro for right roll (e.g., tilting right)
                        } else {
                            crashType = "Left Spin"; // Negative X-gyro for left roll (e.g., tilting left)
                        }
                    }
                    // If dominant is Z-axis (Yaw) or no single axis (X/Y) is dominant above threshold,
                    // it will remain "Unclassified Impact" if not already set by stationary hit.
                    // This is because Yaw is not one of the 5 requested specific spin types.
                }
                // If neither stationary hit nor significant rotation, and conditionsMet was true due to significantImpact only,
                // it will remain "Unclassified Impact" (i.e., a linear impact without specific spin or stationary status).

                Serial.println("Severity: " + String(severity));
                Serial.println("Crash Type: " + crashType);

                // Get timestamp
                String crashTimestamp = getGPSISO8601Time();

                // Construct the SMS message
                String smsMessage = "CRASH ALERT! Severity: " + String(severity) + ", Type: " + crashType +
                                    ". Location: " + String(latitude, 6) + "," + String(longitude, 6) +
                                    ". Speed: " + String(speed_kmph, 2) + " km/h. Time: " + crashTimestamp;
                
                Serial.println("Sending SMS with message: " + smsMessage);
                sendSMS(EMERGENCY_PHONE_NUMBER, smsMessage);

                // Reset crash detection state after successful SMS attempt
                potentialCrash = false;
                potentialCrashStartTime = 0;
                Serial.println("Crash data processed. Resetting detection.");
                // Add a small delay after a confirmed crash to prevent immediate re-triggering
                delay(5000); // Wait 5 seconds before allowing new detection
            }
        }
    } else {
        // Conditions are not met, reset potential crash state
        potentialCrash = false;
        potentialCrashStartTime = 0;
    }
}

void setup() {
    Serial.begin(115200);
    
    // Initialize GPS HardwareSerial with pin remapping
    gpsSerial.begin(9600, SERIAL_8N1, GPS_RX_PIN, GPS_TX_PIN); 

    // Initialize SIM800L HardwareSerial with pin remapping
    sim800lSerial.begin(9600, SERIAL_8N1, SIM_RX_PIN, SIM_TX_PIN); // SIM800L typically uses 9600 baud
    
    Serial.println("Initializing SIM800L...");
    delay(10000); // Give SIM800L time to power up and register on the network

    // Configure SIM800L for SMS text mode
    sim800lSerial.print("AT\r\n"); // Check if SIM800L is responding
    delay(100);
    while (sim800lSerial.available()) {
        Serial.write(sim800lSerial.read());
    }
    Serial.println("Sent AT command.");

    sim800lSerial.print("AT+CMGF=1\r\n"); // Set SMS to text mode
    delay(100);
    while (sim800lSerial.available()) {
        Serial.write(sim800lSerial.read());
    }
    Serial.println("Set SMS to text mode (AT+CMGF=1).");

    Wire.begin(21, 22); // Initialize I2C for MPU6050 (SDA, SCL for ESP32)
    pinMode(FSR_PIN, INPUT); // Set FSR pin as input

    // Initialize MPU6050
    if (!mpu.begin()) {
        Serial.println("Failed to find MPU6050 chip. Continuing without MPU.");
        // Consider adding a flag here to disable MPU-dependent crash detection if MPU fails
    } else {
        Serial.println("MPU6050 Found!");
        mpu.setAccelerometerRange(MPU6050_RANGE_8_G); // Set accelerometer range to 8G
        mpu.setGyroRange(MPU6050_RANGE_500_DEG);      // Set gyro range to 500 deg/s
        mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);   // Set filter bandwidth to reduce noise
    }
}

void loop() {
    // Continuously check for crash conditions
    detectAndUploadCrash();
    delay(100); // Small delay to prevent overwhelming the CPU and allow other tasks
}
