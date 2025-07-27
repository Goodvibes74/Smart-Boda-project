#include <Wire.h>
#include <HardwareSerial.h>
#include <SoftwareSerial.h>
#include <TinyGPS++.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <WiFiClientSecure.h>
#include <NTPClient.h> // For Network Time Protocol client
#include <WiFiUdp.h>   // For UDP communication needed by NTPClient

#define FSR_PIN 35
#define GPS_RX_PIN 34
#define GPS_TX_PIN 32

// Function Declarations
void connectToWiFi();
String getISO8601Time(); // Re-implemented for NTP time
void detectAndUploadCrash();

SoftwareSerial gpsSS(GPS_RX_PIN, GPS_TX_PIN);
TinyGPSPlus gps;
Adafruit_MPU6050 mpu;

// Wi-Fi Configuration
const char* ssid = "IamSavage";
const char* password = "iamsavage";

// NTP Client Configuration
WiFiUDP ntpUDP;
// You can use a different NTP server if preferred, e.g., "pool.ntp.org"
NTPClient timeClient(ntpUDP, "ntp.ubuntu.com", 3 * 3600, 60000); // UTC+3 for Kampala, update every 60 seconds

// Firebase configuration
const String FIREBASE_HOST = "safe-buddy-141a4-default-rtdb.firebaseio.com";
const String FIREBASE_AUTH = "AIzaSyAkY6qkVOfuXhns81HwTICd41ts-LnBQ0Q"; // <<-- VERIFY THIS TOKEN IN FIREBASE CONSOLE
const String FIREBASE_USER_ID = "0766192699";
// Base path for crash data under the user ID
const String FIREBASE_BASE_CRASH_PATH = "/" + FIREBASE_USER_ID + "/";

// Global variables for crash detection state
bool potentialCrash = false;
unsigned long potentialCrashStartTime = 0;
const unsigned long CRASH_DURATION_THRESHOLD_MS = 10; // 10 milliseconds

// Constants for crash detection thresholds
const int FSR_CRASH_THRESHOLD = 500; // FSR value below this indicates biker off seat
const float ACCEL_CRASH_THRESHOLD_G = 3.5; // Requires a much more significant impact
const float GYRO_CRASH_THRESHOLD_DEG_PER_SEC = 100.0; // Requires a much more rapid and violent rotation

// PI constant for radians to degrees conversion
#ifndef PI
#define PI 3.14159265358979323846
#endif

/**
 * @brief Connects the ESP32 to the configured Wi-Fi network.
 * It will keep trying to connect until successful, restarting the ESP32
 * if it fails after a certain number of retries.
 */
void connectToWiFi() {
    Serial.print("Connecting to Wi-Fi...");
    WiFi.begin(ssid, password);
    int retries = 0;
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
        retries++;
        if (retries > 40) { // Timeout after 20 seconds
            Serial.println("\nFailed to connect to Wi-Fi. Restarting ESP...");
            ESP.restart();
        }
    }
    Serial.println("\nWi-Fi connected successfully!");
    Serial.print("IP Address: ");
    Serial.println(WiFi.localIP());
}

/**
 * @brief Gets the current time from the NTP client and formats it into
 * a simplified ISO 8601-like string (YYYY-MM-DD-HH-MM-SS).
 * @return A String representing the formatted current time.
 */
String getISO8601Time() {
    timeClient.update(); // Update the NTP client to get the latest time
    time_t epochTime = timeClient.getEpochTime();
    struct tm *ptm = gmtime(&epochTime); // Use gmtime for UTC, or localtime for local time

    // Format into YYYY-MM-DD-HH-MM-SS
    char formattedTime[20]; // YYYY-MM-DD-HH-MM-SS\0
    sprintf(formattedTime, "%04d-%02d-%02d-%02d-%02d-%02d",
            ptm->tm_year + 1900, // Year since 1900
            ptm->tm_mon + 1,     // Month (0-11)
            ptm->tm_mday,        // Day of month (1-31)
            ptm->tm_hour,        // Hour (0-23)
            ptm->tm_min,         // Minute (0-59)
            ptm->tm_sec);        // Second (0-59)

    return String(formattedTime);
}


/**
 * @brief Detects potential crash events based on sensor data (MPU6050, FSR, GPS)
 * and uploads confirmed crash data to Firebase via HTTP POST.
 */
void detectAndUploadCrash() {
    // 1. Read MPU6050 data (Accelerometer and Gyroscope)
    sensors_event_t a, g, temp;
    mpu.getEvent(&a, &g, &temp);

    // Calculate total acceleration magnitude in G's
    float totalAcceleration_mps2 = sqrt(pow(a.acceleration.x, 2) + pow(a.acceleration.y, 2) + pow(a.acceleration.z, 2));
    float totalAcceleration_g = totalAcceleration_mps2 / 9.80665;

    // Calculate total angular velocity magnitude in degrees per second
    float totalAngularVelocity_radps = sqrt(pow(g.gyro.x, 2) + pow(g.gyro.y, 2) + pow(g.gyro.z, 2));
    float totalAngularVelocity_degps = totalAngularVelocity_radps * (180.0 / PI);

    // 2. Read FSR data (Force Sensitive Resistor for seat detection)
    int fsrValue = analogRead(FSR_PIN);

    // 3. Read GPS data
    while (gpsSS.available() > 0) {
        gps.encode(gpsSS.read());
    }

    double latitude = gps.location.isValid() ? gps.location.lat() : 0.0;
    double longitude = gps.location.isValid() ? gps.location.lng() : 0.0;
    double speed_kmph = gps.speed.isValid() ? gps.speed.kmph() : 0.0;

    // Determine crash type based on rotational change thresholds
    String crashType = "Unknown";
    int severity = 0;
    if (totalAngularVelocity_degps >= 150.0) {
        crashType = "Severe Rotational Impact";
        severity = 3;
    } else if (totalAngularVelocity_degps >= 120.0) {
        crashType = "Moderate Rotational Impact";
        severity = 2;
    } else if (totalAngularVelocity_degps >= GYRO_CRASH_THRESHOLD_DEG_PER_SEC) {
        crashType = "Minor Rotational Impact";
        severity = 1;
    }

    // Check if current conditions meet the criteria for a potential crash
    bool conditionsMet = (fsrValue < FSR_CRASH_THRESHOLD &&
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

                // Get current ISO 8601 formatted time for the Firebase node key
                String crashTimestamp = getISO8601Time();
                // Construct the full Firebase URL, WITHOUT .json extension
                String crashPath = "/" + FIREBASE_USER_ID + "/" + crashTimestamp + "?auth=" + FIREBASE_AUTH;
                String fullURL = "https://" + FIREBASE_HOST + crashPath; // Use HTTPS

                // Construct the JSON data payload
                String jsonData = "{";
                jsonData += "\"latitude\":" + String(latitude, 6) + ",";
                jsonData += "\"longitude\":" + String(longitude, 6) + ",";
                jsonData += "\"severity\":" + String(severity) + ",";
                jsonData += "\"speed_kmph\":" + String(speed_kmph, 2) + ",";
                jsonData += "\"crash_type\":\"" + crashType + "\"";
                jsonData += "}";

                Serial.println("Attempting to upload crash data to: " + fullURL);
                Serial.println("JSON Payload: " + jsonData);

                // --- Firebase Upload Logic ---
                if (WiFi.status() == WL_CONNECTED) {
                    WiFiClientSecure client;
                    client.setInsecure(); // WARNING: For production, add root certificates!
                    HTTPClient http;
                    http.begin(client, fullURL);
                    http.addHeader("Content-Type", "application/json");

                    Serial.println("Sending HTTP POST request...");
                    int httpResponseCode = http.POST(jsonData);

                    if (httpResponseCode > 0) {
                        Serial.print("HTTP POST successful! Response code: ");
                        Serial.println(httpResponseCode);
                        String payload = http.getString();
                        Serial.println("Firebase Response: " + payload);
                    } else {
                        Serial.print("HTTP POST failed! Error code: ");
                        Serial.println(httpResponseCode);
                        Serial.println("HTTP Error Reason: " + http.errorToString(httpResponseCode));
                    }
                    http.end();
                } else {
                    Serial.println("WiFi not connected. Cannot upload data. Attempting reconnect.");
                    connectToWiFi();
                }

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
    gpsSS.begin(9600);
    Wire.begin(21, 22);
    pinMode(FSR_PIN, INPUT);

    if (!mpu.begin()) {
        Serial.println("Failed to find MPU6050 chip. Continuing without MPU.");
    } else {
        Serial.println("MPU6050 Found!");
    }

    connectToWiFi(); // Connect to Wi-Fi first
    timeClient.begin(); // Start the NTP client
    // Set time synchronization for ESP32 internal clock (optional, but good practice)
    // You might need to adjust the timezone offset here if your NTP server isn't providing UTC
    configTime(3 * 3600, 0, "ntp.ubuntu.com"); // 3 * 3600 for EAT (UTC+3)
    Serial.println("NTP client started. Waiting for time sync...");
    // Wait for time to be set
    while (!timeClient.update()) {
        timeClient.forceUpdate();
        Serial.print(".");
        delay(500);
    }
    Serial.println("\nTime synchronized!");
    Serial.println("Current time: " + getISO8601Time());
}

void loop() {
    detectAndUploadCrash();
    delay(100);
}