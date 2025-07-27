#include <Wire.h>
#include <HardwareSerial.h>
#include <SoftwareSerial.h>
#include <TinyGPS++.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>

#define SIM_RX_PIN 26
#define SIM_TX_PIN 27
#define FSR_PIN 35
#define GPS_RX_PIN 34
#define GPS_TX_PIN 32

// Function Declarations
void sendAT(String command, const char* expectedResponse = "OK", int timeout = 5000);
String getISO8601Time();
void detectAndUploadCrash();

HardwareSerial sim800l(Serial2);
SoftwareSerial gpsSS(GPS_RX_PIN, GPS_TX_PIN);
TinyGPSPlus gps;
Adafruit_MPU6050 mpu;

// Firebase configuration
const String FIREBASE_HOST = "safe-buddy-141a4-default-rtdb.firebaseio.com";
const String FIREBASE_AUTH = "AIzaSyAkY6qkVOfuXhns81HwTICd41ts-LnBQ0Q";
const String FIREBASE_USER_ID = "0766192699";
// Base path for crash data under the user ID
const String FIREBASE_BASE_CRASH_PATH = "/" + FIREBASE_USER_ID + "/";

// GSM specific definitions
String apn = "internet";

// Global variables for crash detection state
bool potentialCrash = false;
unsigned long potentialCrashStartTime = 0;
const unsigned long CRASH_DURATION_THRESHOLD_MS = 10; // 10 milliseconds

// Constants for crash detection thresholds (adjusted based on Dart code)
const int FSR_CRASH_THRESHOLD = 500; // FSR value below this indicates biker off seat
const float ACCEL_CRASH_THRESHOLD_G = 1.215; // Acceleration in G's (from Dart crashGThreshold)
const float GYRO_CRASH_THRESHOLD_DEG_PER_SEC = 25.8; // Angular velocity in degrees per second (0.45 rad/s converted to deg/s)
const float SPEED_CRASH_THRESHOLD_KMPH = 10.0; // Minimum GPS speed for crash detection (from Dart speed > 10)

// PI constant for radians to degrees conversion
#ifndef PI
#define PI 3.14159265358979323846
#endif

// Helper function to send AT commands and wait for response
void sendAT(String command, const char* expectedResponse, int timeout) {
    sim800l.println(command);
    unsigned long startTime = millis();
    String response;

    while (millis() - startTime < timeout) {
        while (sim800l.available()) {
            char c = sim800l.read();
            response += c;
        }

        if (response.indexOf(expectedResponse) != -1) {
            Serial.println("AT OK: " + command);
            Serial.println("Response: " + response);
            return;
        }
    }

    Serial.println("AT command failed or timed out: " + command);
    Serial.println("Response: " + response);
}

// Function to get the current time from the SIM800L module and format it
// in a simplified ISO 8601-like format for the database key.
String getISO8601Time() {
    sendAT("AT+CCLK?", "+CCLK:", 5000);
    String response;
    unsigned long startTime = millis();
    while (millis() - startTime < 2000 && sim800l.available()) {
        response += (char)sim800l.read();
    }

    // Example response: "+CCLK: "25/07/25,13:43:55+03""
    int startIndex = response.indexOf("\"") + 1;
    if (startIndex > 0) {
        String timeString = response.substring(startIndex);
        // Extract year, month, day, hour, minute, second
        String year = timeString.substring(0, 2);
        String month = timeString.substring(3, 5);
        String day = timeString.substring(6, 8);
        String hour = timeString.substring(9, 11);
        String minute = timeString.substring(12, 14);
        String second = timeString.substring(15, 17);

        // Format into YYYY-MM-DD-HH-MM-SS
        String formattedTime = "20" + year + "-" + month + "-" + day + "-" + hour + "-" + minute + "-" + second;
        return formattedTime;
    }
    return "";
}

// Function to detect and upload crash data
void detectAndUploadCrash() {
    // 1. Read MPU6050 data
    sensors_event_t a, g, temp;
    mpu.getEvent(&a, &g, &temp);

    // Calculate total acceleration magnitude in G's
    float totalAcceleration_mps2 = sqrt(pow(a.acceleration.x, 2) + pow(a.acceleration.y, 2) + pow(a.acceleration.z, 2));
    float totalAcceleration_g = totalAcceleration_mps2 / 9.80665; // Convert m/s^2 to G's

    // Calculate total angular velocity magnitude in degrees per second
    float totalAngularVelocity_radps = sqrt(pow(g.gyro.x, 2) + pow(g.gyro.y, 2) + pow(g.gyro.z, 2));
    float totalAngularVelocity_degps = totalAngularVelocity_radps * (180.0 / PI);

    // 2. Read FSR data
    int fsrValue = analogRead(FSR_PIN);

    // 3. Read GPS data
    while (gpsSS.available() > 0) {
        gps.encode(gpsSS.read());
    }

    double latitude = gps.location.isValid() ? gps.location.lat() : 0.0;
    double longitude = gps.location.isValid() ? gps.location.lng() : 0.0;
    double speed_kmph = gps.speed.isValid() ? gps.speed.kmph() : 0.0;

    // Determine crash type based on rotational change
    String crashType = "Unknown";
    int severity = 0; // Default severity
    if (totalAngularVelocity_degps >= 90.0) {
        crashType = "Severe Rotational Impact";
        severity = 3; // Severe
    } else if (totalAngularVelocity_degps >= 50.0) {
        crashType = "Moderate Rotational Impact";
        severity = 2; // Moderate
    } else if (totalAngularVelocity_degps >= GYRO_CRASH_THRESHOLD_DEG_PER_SEC) {
        crashType = "Minor Rotational Impact";
        severity = 1; // Minor
    }

    // Check current crash conditions, now incorporating speed and OR logic for accel/gyro
    bool conditionsMet = (fsrValue < FSR_CRASH_THRESHOLD &&
                          speed_kmph > SPEED_CRASH_THRESHOLD_KMPH &&
                          (totalAcceleration_g >= ACCEL_CRASH_THRESHOLD_G || totalAngularVelocity_degps >= GYRO_CRASH_THRESHOLD_DEG_PER_SEC));

    if (conditionsMet) {
        if (!potentialCrash) {
            potentialCrash = true;
            potentialCrashStartTime = millis();
            Serial.println("Potential crash conditions met. Starting timer...");
        } else {
            if (millis() - potentialCrashStartTime >= CRASH_DURATION_THRESHOLD_MS) {
                // CRASH CONFIRMED!
                Serial.println("CRASH DETECTED!");
                Serial.println("FSR: " + String(fsrValue));
                Serial.println("Accel (G): " + String(totalAcceleration_g));
                Serial.println("Gyro (deg/s): " + String(totalAngularVelocity_degps));
                Serial.println("Latitude: " + String(latitude, 6));
                Serial.println("Longitude: " + String(longitude, 6));
                Serial.println("Speed (km/h): " + String(speed_kmph, 2));
                Serial.println("Crash Type: " + crashType);


                // **NEW: GET TIMESTAMP AND CONSTRUCT DYNAMIC URL**
                String crashTimestamp = getISO8601Time();
                String crashPath = FIREBASE_BASE_CRASH_PATH + crashTimestamp + ".json?auth=" + FIREBASE_AUTH;
                String fullURL = "http://" + FIREBASE_HOST + crashPath;

                // Construct JSON string
                String jsonData = "{";
                jsonData += "\"latitude\":" + String(latitude, 6) + ",";
                jsonData += "\"longitude\":" + String(longitude, 6) + ",";
                jsonData += "\"severity\":" + String(severity) + ",";
                jsonData += "\"speed_kmph\":" + String(speed_kmph, 2) + ",";
                jsonData += "\"crash_type\":\"" + crashType + "\"";
                jsonData += "}";

                Serial.println("Uploading crash data to: " + fullURL);
                Serial.println("JSON: " + jsonData);

                // --- Firebase Upload Logic for Crash Data ---
                sendAT("AT+HTTPPARA=\"URL\",\"" + fullURL + "\"");
                sendAT("AT+HTTPPARA=\"CONTENT\",\"application/json\"");

                sendAT("AT+HTTPDATA=" + String(jsonData.length()) + ",10000", "DOWNLOAD", 10000);
                delay(100);
                sim800l.print(jsonData);
                delay(2000);

                sendAT("AT+HTTPACTION=1", "+HTTPACTION:", 10000); // HTTP POST

                // HTTPREAD to view response (optional, for debugging)
                sendAT("AT+HTTPREAD", "OK", 10000);

                // Reset crash detection state
                potentialCrash = false;
                potentialCrashStartTime = 0;
                Serial.println("Crash data uploaded. Resetting detection.");
                delay(5000);
            }
        }
    } else {
        potentialCrash = false;
        potentialCrashStartTime = 0;
    }
}

void setup() {
    Serial.begin(115200);
    sim800l.begin(9600);
    gpsSS.begin(9600);
    Wire.begin(21, 22);
    pinMode(FSR_PIN, INPUT);

    if (!mpu.begin()) {
        Serial.println("Failed to find MPU6050 chip. Continuing without MPU.");
    } else {
        Serial.println("MPU6050 Found!");
    }

    // --- GSM Initialization ---
    delay(3000);
    Serial.println("Initializing SIM800L...");

    sendAT("AT");
    sendAT("ATE0");
    sendAT("AT+CSQ");
    sendAT("AT+CPIN?");
    sendAT("AT+CREG?");

    Serial.println("Setting up GPRS...");
    sendAT("AT+CSTT=\"" + apn + "\"");
    sendAT("AT+CIICR");
    sendAT("AT+CIFSR", ".", 10000);

    Serial.println("Initializing HTTP...");
    sendAT("AT+HTTPINIT");
    sendAT("AT+HTTPPARA=\"CID\",1");
}

void loop() {
    detectAndUploadCrash();
    delay(100);
}