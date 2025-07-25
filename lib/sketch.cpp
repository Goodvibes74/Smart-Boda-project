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
void detectAndUploadCrash();

HardwareSerial sim800l(Serial2);
SoftwareSerial gpsSS(GPS_RX_PIN, GPS_TX_PIN);
TinyGPSPlus gps;
Adafruit_MPU6050 mpu;

// Firebase configuration
const String FIREBASE_HOST = "safe-buddy-141a4-default-rtdb.firebaseio.com";
const String FIREBASE_AUTH = "AIzaSyAkY6qkVOfuXhns81HwTICd41ts-LnBQ0Q";
const String FIREBASE_BASE_URL = "https://" + FIREBASE_HOST + "/";
// Changed path to /crashData for specific crash uploads
const String FIREBASE_CRASH_PATH = "/crashData.json?auth=" + FIREBASE_AUTH;

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

// Function to detect and upload crash data
void detectAndUploadCrash() {
  // 1. Read MPU6050 data
  sensors_event_t a, g, temp;
  mpu.getEvent(&a, &g, &temp);

  // Calculate total acceleration magnitude in G's
  float totalAcceleration_mps2 = sqrt(pow(a.acceleration.x, 2) + pow(a.acceleration.y, 2) + pow(a.acceleration.z, 2));
  float totalAcceleration_g = totalAcceleration_mps2 / 9.80665; // Convert m/s^2 to G's

  // Calculate total angular velocity magnitude in degrees per second
  // Gyro readings are typically in rad/s, convert to deg/s
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
  // Get speed in kilometers per hour
  double speed_kmph = gps.speed.isValid() ? gps.speed.kmph() : 0.0;

  // Determine crash type based on rotational change
  String crashType = "Unknown";
  if (totalAngularVelocity_degps >= 90.0) {
    crashType = "Severe Rotational Impact";
  } else if (totalAngularVelocity_degps >= 50.0) {
    crashType = "Moderate Rotational Impact";
  } else if (totalAngularVelocity_degps >= GYRO_CRASH_THRESHOLD_DEG_PER_SEC) {
    crashType = "Minor Rotational Impact";
  }


  // Check current crash conditions, now incorporating speed and OR logic for accel/gyro
  bool conditionsMet = (fsrValue < FSR_CRASH_THRESHOLD &&
                        speed_kmph > SPEED_CRASH_THRESHOLD_KMPH &&
                        (totalAcceleration_g >= ACCEL_CRASH_THRESHOLD_G || totalAngularVelocity_degps >= GYRO_CRASH_THRESHOLD_DEG_PER_SEC));

  if (conditionsMet) {
    if (!potentialCrash) {
      // Conditions just met, start potential crash timer
      potentialCrash = true;
      potentialCrashStartTime = millis();
      Serial.println("Potential crash conditions met. Starting timer...");
    } else {
      // Conditions still met, check if duration threshold is reached
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


        // Assign a fixed severity for now
        int severity = 5; // Can be made dynamic based on sensor values if needed

        // Construct JSON string with location, severity, speed, and crash type
        String jsonData = "{";
        jsonData += "\"latitude\":" + String(latitude, 6) + ",";
        jsonData += "\"longitude\":" + String(longitude, 6) + ",";
        jsonData += "\"severity\":" + String(severity) + ",";
        jsonData += "\"speed_kmph\":" + String(speed_kmph, 2) + ",";
        jsonData += "\"crash_type\":\"" + crashType + "\"";
        jsonData += "}";

        Serial.println("Uploading crash data: " + jsonData);

        // --- Firebase Upload Logic for Crash Data ---
        // Need to re-set HTTPPARA URL if it was set for sensorData.json previously
        sendAT("AT+HTTPPARA=\"URL\",\"http://" + FIREBASE_HOST + FIREBASE_CRASH_PATH + "\"");
        sendAT("AT+HTTPPARA=\"CONTENT\",\"application/json\"");

        sendAT("AT+HTTPDATA=" + String(jsonData.length()) + ",10000", "DOWNLOAD", 10000);
        delay(100); // Slight delay before sending data
        sim800l.print(jsonData); // Send JSON data
        delay(2000); // Allow module to buffer data

        sendAT("AT+HTTPACTION=1", "+HTTPACTION:", 10000); // HTTP POST

        // HTTPREAD to view response (optional, for debugging)
        sendAT("AT+HTTPREAD", "OK", 10000);

        // Reset crash detection state to prevent multiple uploads for the same event
        potentialCrash = false;
        potentialCrashStartTime = 0;
        Serial.println("Crash data uploaded. Resetting detection.");
        delay(5000); // Add a delay after upload to prevent immediate re-detection
      }
    }
  } else {
    // Conditions not met, reset potential crash state
    potentialCrash = false;
    potentialCrashStartTime = 0;
  }
}

void setup() {
  Serial.begin(115200); // For debugging
  sim800l.begin(9600);
  gpsSS.begin(9600);
  Wire.begin(21, 22); // Initialize Wire with SDA on 21 and SCL on 22
  pinMode(FSR_PIN, INPUT); // Initialize FSR pin as input

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
  sendAT("AT+CIFSR", ".", 10000); // Show IP address

  Serial.println("Initializing HTTP...");
  sendAT("AT+HTTPINIT");
  sendAT("AT+HTTPPARA=\"CID\",1");
  // NOTE: HTTPPARA URL and CONTENT-TYPE are now set within detectAndUploadCrash()
  // to allow dynamic switching if needed, or to ensure they are correct for crash data.
  // If you only ever upload crash data, you can set them here once.
}

void loop() {
  // Call the crash detection function
  detectAndUploadCrash();

  // Add a small delay to prevent rapid loop execution and excessive sensor reads/AT commands
  delay(100);
}
