#include <Wire.h>
#include <HardwareSerial.h>
#include <SoftwareSerial.h>
#include <TinyGPS++.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <WiFiClientSecure.h>

#include <time.h> // Include for time manipulation functions

#define FSR_PIN 35
#define GPS_RX_PIN 34
#define GPS_TX_PIN 32

// Function Declarations
void connectToWiFi();
String getGPSISO8601Time();
void detectAndUploadCrash();

SoftwareSerial gpsSS(GPS_RX_PIN, GPS_TX_PIN);
TinyGPSPlus gps;
Adafruit_MPU6050 mpu;

// Wi-Fi Configuration
const char* ssid = "IamSavage";
const char* password = "iamsavage";

// Firebase configuration
const String FIREBASE_HOST = "safe-buddy-141a4-default-rtdb.firebaseio.com";
const String FIREBASE_AUTH = "AIzaSyAkY6qkVOfuXhns81HwTICd41ts-LnBQ0Q"; // WARNING: Hardcoded API key is a security risk.
const String FIREBASE_USER_ID = "0766192699";
const String FIREBASE_BASE_CRASH_PATH = "/" + FIREBASE_USER_ID + "/";

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

void connectToWiFi() {
    Serial.print("Connecting to Wi-Fi...");
    WiFi.begin(ssid, password);
    int retries = 0;
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
        retries++;
        if (retries > 40) { // 20 seconds timeout (40 * 500ms)
            Serial.println("\nFailed to connect to Wi-Fi. Restarting ESP...");
            ESP.restart(); // Restart ESP if Wi-Fi connection fails after multiple retries
        }
    }
    Serial.println("\nWi-Fi connected successfully!");
    Serial.print("IP Address: ");
    Serial.println(WiFi.localIP());
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

void detectAndUploadCrash() {
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
    while (gpsSS.available() > 0) {
        gps.encode(gpsSS.read());
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

                // Construct Firebase URL and JSON payload
                String crashPath = "/" + FIREBASE_USER_ID + "/" + crashTimestamp + ".json?auth=" + FIREBASE_AUTH;
                String fullURL = "https://" + FIREBASE_HOST + crashPath;

                String jsonData = "{";
                jsonData += "\"latitude\":" + String(latitude, 6) + ",";
                jsonData += "\"longitude\":" + String(longitude, 6) + ",";
                jsonData += "\"severity\":" + String(severity) + ",";
                jsonData += "\"speed_kmph\":" + String(speed_kmph, 2) + ",";
                jsonData += "\"crash_type\":\"" + crashType + "\"";
                jsonData += "}";

                Serial.println("Attempting to upload crash data to: " + fullURL);
                Serial.println("JSON Payload: " + jsonData);

                // 6. Upload Data to Firebase
                if (WiFi.status() == WL_CONNECTED) {
                    WiFiClientSecure client;
                    // WARNING: client.setInsecure() disables SSL certificate validation.
                    // This is NOT recommended for production environments as it makes your connection vulnerable.
                    // For production, proper certificate handling (e.g., client.setCACert()) should be implemented.
                    // client.setInsecure(); // Commented out for security best practice
                    HTTPClient http;
                    http.begin(client, fullURL);
                    http.addHeader("Content-Type", "application/json");
                    Serial.println("Sending HTTP PUT request...");
                    int httpResponseCode = http.PUT(jsonData);

                    if (httpResponseCode > 0) {
                        Serial.print("HTTP PUT successful! Response code: ");
                        Serial.println(httpResponseCode);
                        String payload = http.getString();
                        Serial.println("Firebase Response: " + payload);
                    } else {
                        Serial.print("HTTP PUT failed! Error code: ");
                        Serial.println(httpResponseCode);
                        Serial.println("HTTP Error Reason: " + http.errorToString(httpResponseCode));
                    }
                    http.end();
                } else {
                    Serial.println("WiFi not connected. Cannot upload data. Attempting reconnect.");
                    connectToWiFi(); // Attempt to reconnect if disconnected
                }

                // Reset crash detection state after successful upload or failed attempt
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
    gpsSS.begin(9600); // Initialize GPS SoftwareSerial
    Wire.begin(21, 22); // Initialize I2C for MPU6050 (SDA, SCL for ESP32)
    pinMode(FSR_PIN, INPUT); // Set FSR pin as input

    // Initialize MPU6050
    if (!mpu.begin()) {
        Serial.println("Failed to find MPU6050 chip. Continuing without MPU.");
        // Consider adding a flag here to disable MPU-dependent crash detection if MPU fails
    } else {
        Serial.println("MPU6050 Found!");
        mpu.setAccelerometerRange(MPU6050_RANGE_8_G); // Set accelerometer range to 8G
        mpu.setGyroRange(MPU6050_RANGE_500_DEG);     // Set gyro range to 500 deg/s
        mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);  // Set filter bandwidth to reduce noise
    }

    // Connect to Wi-Fi
    connectToWiFi();
}

void loop() {
    // Continuously check for crash conditions
    detectAndUploadCrash();
    delay(100); // Small delay to prevent overwhelming the CPU and allow other tasks
}
