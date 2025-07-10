#include <Wire.h>
#include <SoftwareSerial.h>
#include <TinyGPS++.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>

/* ----------  forward prototypes  ---------- */
void sendAT(const char *cmd, uint32_t timeout = 2000);
void waitNetwork();
void setupGPRS();
void uploadToFirestore(float lat, float lon, float ax, float ay, float az, float gx, float gy, float gz);
String getISOTime();  // helper for timestamp string
/* ------------------------------------------ */

// --- SIM800L -------------------------------------------------
#define SIM_RX_PIN 16
#define SIM_TX_PIN 17
#define FSR_PIN 33
SoftwareSerial sim800l(SIM_RX_PIN, SIM_TX_PIN);

// --- NEO‑6M --------------------------------------------------
#define GPS_RX_PIN 34
#define GPS_TX_PIN 32
SoftwareSerial gpsSS(GPS_RX_PIN, GPS_TX_PIN);
TinyGPSPlus  gps;

// --- MPU‑6050 -----------------------------------------------
Adafruit_MPU6050 mpu;

// --- Firebase credentials ------------------------------------
const char* FIREBASE_PROJECT_ID = "safe-buddy-141a4";       // Replace with your Firebase project ID
const char* FIREBASE_API_KEY = "AIzaSyAkY6qkVOfuXhns81HwTICd41ts-LnBQ0Q";         // Replace with your Firebase Web API Key
const char* DEVICE_ID = "device_001";                       // Unique device ID

// --- Timing --------------------------------------------------
unsigned long lastUpload = 0;
const unsigned long UPLOAD_MS = 100;   // 100 ms

// -----------------------------------------------------------------
void setup() {
  Serial.begin(115200);
  gpsSS.begin(9600);
  sim800l.begin(9600);
  pinMode(FSR_PIN, INPUT);

  Serial.println(F("Init MPU‑6050…"));
  Wire.begin(21, 22);  // Explicitly set I2C pins if not already
  Serial.println("Scanning I2C devices...");
  byte count = 0;
  for (byte address = 1; address < 127; ++address) {
    Wire.beginTransmission(address);
    if (Wire.endTransmission() == 0) {
      Serial.print("MPU-6050 found at 0x");
      Serial.println(address, HEX);
      count++;
    }
  }
  if (count == 0) {
    Serial.println("No I2C devices found.");
  }

  while (!mpu.begin()) {
    Serial.println(F("MPU6050 not found. Retrying..."));
    delay(1000);  // Wait and retry
  }

  mpu.setAccelerometerRange(MPU6050_RANGE_8_G);
  mpu.setGyroRange(MPU6050_RANGE_500_DEG);
  mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);

  Serial.println(F("Init SIM800L…"));
  sendAT("AT");
  sendAT("AT+CPIN?");
  setupGPRS();
}

// -----------------------------------------------------------------
void loop() {
  while (gpsSS.available()) gps.encode(gpsSS.read());

  int fsrValue = analogRead(FSR_PIN);

  sensors_event_t a, g, temp;
  mpu.getEvent(&a, &g, &temp);

  if (millis() - lastUpload > UPLOAD_MS) {
    lastUpload = millis();

    if (gps.location.isValid()) {
      float lat = gps.location.lat();
      float lon = gps.location.lng();
      float ax  = a.acceleration.x;
      float ay  = a.acceleration.y;
      float az  = a.acceleration.z;
      float gx  = g.gyro.x;
      float gy  = g.gyro.y;
      float gz  = g.gyro.z;

      Serial.print(F("→ Uploading: "));
      Serial.print(lat, 6); Serial.print(F(", "));
      Serial.print(lon, 6); Serial.print(F(", "));
      Serial.print(ax); Serial.print(F(", "));
      Serial.print(ay); Serial.print(F(", "));
      Serial.print(az); Serial.print(F(", "));
      Serial.print(gx); Serial.print(F(", "));
      Serial.print(gy); Serial.print(F(", "));
      Serial.println(gz);
      Serial.print("FSR Reading: ");
      Serial.println(fsrValue);

      uploadToFirestore(lat, lon, ax, ay, az, gx, gy, gz);
    } else {
      Serial.println(F("GPS not fixed yet"));
    }
  }
}

// --------------- Helper functions ------------------------------
void sendAT(const char *cmd, uint32_t timeout) {
  sim800l.println(cmd);
  unsigned long t0 = millis();
  while (millis() - t0 < timeout) {
    while (sim800l.available()) Serial.write(sim800l.read());
  }
}

void waitNetwork() {
  Serial.println(F("Waiting network…"));
  while (true) {
    sim800l.println("AT+CREG?");
    unsigned long t0 = millis();
    String response = "";
    while (millis() - t0 < 2000) {
      while (sim800l.available()) {
        char c = sim800l.read();
        response += c;
      }
    }

    Serial.print("Response: "); Serial.println(response);

    if (response.indexOf("+CREG: 0,1") != -1 || response.indexOf("+CREG: 0,5") != -1) {
      Serial.println("Network registered.");
      break;
    }

    Serial.print(".");
    delay(1000);
  }
}


void setupGPRS() {
  Serial.println(F("GPRS attach…"));
  sendAT("AT+SAPBR=3,1,\"CONTYPE\",\"GPRS\"");
  sim800l.print(F("AT+SAPBR=3,1,\"APN\",\"")); sim800l.print("internet"); sim800l.println('"'); // Change APN if needed
  sendAT("", 1500);                    // flush
  sendAT("AT+SAPBR=1,1", 5000);
  sendAT("AT+SAPBR=2,1");
}

// Upload data to Firestore using REST API via SIM800L HTTP POST
void uploadToFirestore(float lat, float lon, float ax, float ay, float az, float gx, float gy, float gz) {
  String firestoreUrl = String("https://firestore.googleapis.com/v1/projects/") +
                        FIREBASE_PROJECT_ID +
                        "/databases/(default)/documents/accident_detector/" +
                        DEVICE_ID +
                        "/data?key=" +
                        FIREBASE_API_KEY;

  // JSON payload with Firestore typed fields
  String json = "{";
  json += "\"fields\": {";
  json += "\"lat\": {\"doubleValue\": " + String(lat, 6) + "},";
  json += "\"lon\": {\"doubleValue\": " + String(lon, 6) + "},";
  json += "\"ax\": {\"doubleValue\": " + String(ax, 6) + "},";
  json += "\"ay\": {\"doubleValue\": " + String(ay, 6) + "},";
  json += "\"az\": {\"doubleValue\": " + String(az, 6) + "},";
  json += "\"gx\": {\"doubleValue\": " + String(gx, 6) + "},";
  json += "\"gy\": {\"doubleValue\": " + String(gy, 6) + "},";
  json += "\"gz\": {\"doubleValue\": " + String(gz, 6) + "},";
  // Option 1: Provide ISO timestamp yourself:
  json += "\"timestamp\": {\"timestampValue\": \"" + getISOTime() + "\"}";
  // Option 2: Omit timestamp here, set with Firebase ServerTimestamp in rules or backend
  json += "}}";

  sendAT("AT+HTTPTERM");
  sendAT("AT+HTTPINIT");
  sendAT("AT+HTTPPARA=\"CID\",1");
  sim800l.print("AT+HTTPPARA=\"URL\",\""); sim800l.print(firestoreUrl); sim800l.println("\"");
  delay(100);
  sendAT("AT+HTTPPARA=\"CONTENT\",\"application/json\"");

  sim800l.print("AT+HTTPDATA="); sim800l.print(json.length()); sim800l.println(",10000");
  delay(1000);
  sim800l.print(json);
  delay(1000);

  sendAT("AT+HTTPACTION=1", 8000);  // POST
  sendAT("AT+HTTPREAD", 2000);
  sendAT("AT+HTTPTERM");
}

// Returns current time in ISO 8601 format, e.g. "2025-07-09T12:34:56Z"
// You need to implement this based on your RTC or GPS time
String getISOTime() {
  if (gps.time.isValid() && gps.date.isValid()) {
    char buf[25];
    sprintf(buf, "%04d-%02d-%02dT%02d:%02d:%02dZ",
            gps.date.year(), gps.date.month(), gps.date.day(),
            gps.time.hour(), gps.time.minute(), gps.time.second());
    return String(buf);
  } else {
    return "1970-01-01T00:00:00Z";
  }
}
