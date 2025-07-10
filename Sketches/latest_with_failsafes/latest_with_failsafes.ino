#include <Wire.h>
#include <TinyGPS++.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>

/* ----------  Forward Prototypes  ---------- */
void sendAT(const char *cmd, uint32_t timeout = 2000);
void waitNetwork();
void setupGPRS();
void uploadToFirestore(float lat, float lon, float ax, float ay, float az, float gx, float gy, float gz);
String getISOTime();
/* ------------------------------------------ */

// --- SIM800L UART1 -------------------------------------------------
#define SIM_RX_PIN 16
#define SIM_TX_PIN 17
HardwareSerial sim800l(1);  // UART1

// --- GPS NEO-6M UART2 ----------------------------------------------
#define GPS_RX_PIN 32  // GPS ← ESP32 TX
#define GPS_TX_PIN 34  // GPS → ESP32 RX
HardwareSerial gpsSS(2);    // UART2
TinyGPSPlus gps;

// --- MPU‑6050 -----------------------------------------------------
Adafruit_MPU6050 mpu;

// --- Firebase credentials ------------------------------------------
const char* FIREBASE_PROJECT_ID = "YOUR_PROJECT_ID";       // Replace with your Firebase project ID
const char* FIREBASE_API_KEY    = "YOUR_WEB_API_KEY";      // Replace with your Firebase Web API Key
const char* DEVICE_ID           = "device_001";            // Unique device ID

// --- Timing --------------------------------------------------------
unsigned long lastUpload = 0;
const unsigned long UPLOAD_MS = 5000;   // Upload every 5 seconds

// -------------------------------------------------------------------
void setup() {
  Serial.begin(115200);
  gpsSS.begin(9600, SERIAL_8N1, GPS_TX_PIN, GPS_RX_PIN);
  sim800l.begin(9600, SERIAL_8N1, SIM_RX_PIN, SIM_TX_PIN);

  Serial.println(F("Initializing MPU6050…"));
  if (!mpu.begin()) {
    Serial.println(F("MPU6050 not found; halting"));
    while (true) {}
  }
  mpu.setAccelerometerRange(MPU6050_RANGE_8_G);
  mpu.setGyroRange(MPU6050_RANGE_500_DEG);
  mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);

  Serial.println(F("Initializing SIM800L…"));
  sendAT("AT");
  sendAT("AT+CPIN?");
  waitNetwork();
  setupGPRS();
}

// -------------------------------------------------------------------
void loop() {
  while (gpsSS.available()) gps.encode(gpsSS.read());

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
      Serial.print(gy); Serial.println(gz);

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
  Serial.print(F("Waiting for network "));
  while (true) {
    sim800l.println(F("AT+CREG?"));
    delay(1000);
    if (sim800l.find(const_cast<char*>("+CREG: 0,1")) ||
        sim800l.find(const_cast<char*>("+CREG: 0,5"))) {
      Serial.println(F("Connected"));
      break;
    }
    Serial.print('.');
  }
}

void setupGPRS() {
  Serial.println(F("Attaching GPRS…"));
  sendAT("AT+SAPBR=3,1,\"CONTYPE\",\"GPRS\"");
  sim800l.print(F("AT+SAPBR=3,1,\"APN\",\"internet\"\r"));  // Replace "internet" with your APN
  sendAT("", 1500);  // Flush
  sendAT("AT+SAPBR=1,1", 5000);
  sendAT("AT+SAPBR=2,1");
}

void uploadToFirestore(float lat, float lon, float ax, float ay, float az, float gx, float gy, float gz) {
  String firestoreUrl = String("https://firestore.googleapis.com/v1/projects/") +
                        FIREBASE_PROJECT_ID +
                        "/databases/(default)/documents/accident_detector/" +
                        DEVICE_ID +
                        "/data?key=" +
                        FIREBASE_API_KEY;

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
  json += "\"timestamp\": {\"timestampValue\": \"" + getISOTime() + "\"}";
  json += "}}";

  sendAT("AT+HTTPTERM");
  sendAT("AT+HTTPINIT");
  sendAT("AT+HTTPPARA=\"CID\",1");
  sim800l.print("AT+HTTPPARA=\"URL\",\""); sim800l.print(firestoreUrl); sim800l.println("\"");
  delay(100);
  sendAT("AT+HTTPPARA=\"CONTENT\",\"application/json\"");

  sim800l.print("AT+HTTPDATA="); sim800l.print(json.length()); sim800l.println(",10000");
  delay(100);
  sim800l.print(json);
  delay(1000);

  sendAT("AT+HTTPACTION=1", 8000);  // POST
  sendAT("AT+HTTPREAD", 2000);
  sendAT("AT+HTTPTERM");
}

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
