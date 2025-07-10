#include <Wire.h>
#include <SoftwareSerial.h>
#include <TinyGPS++.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>

/* ----------  forward prototypes  ---------- */
void sendAT(const char *cmd, uint32_t timeout = 2000);
void waitNetwork();
void setupGPRS();
void uploadToThingSpeak(float lat, float lon, float ax, float ay, float az, float gx, float gy, float gz, unsigned long bootTime);
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

// --- Timing --------------------------------------------------
unsigned long lastUpload = 0;
const unsigned long UPLOAD_MS = 100;   // 100 ms
unsigned long bootSeconds = 0;

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
  waitNetwork();
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
    bootSeconds = millis() / 1000;

    float lati = 0.0, lon = 0.0;
    float ax = 0.0, ay = 0.0, az = 0.0;
    float gx = 0.0, gy = 0.0, gz = 0.0;

    lati = gps.location.lat();
    lon = gps.location.lng();

    ax  = a.acceleration.x;
    ay  = a.acceleration.y;
    az  = a.acceleration.z;
    gx  = g.gyro.x;
    gy  = g.gyro.y;
    gz  = g.gyro.z;

    Serial.print(F("→ Uploading: "));
    Serial.print(lati, 6); Serial.print(F(", "));
    Serial.print(lon, 6); Serial.print(F(", "));
    Serial.print(ax); Serial.print(F(", "));
    Serial.print(ay); Serial.print(F(", "));
    Serial.print(az); Serial.print(F(", "));
    Serial.print(gx); Serial.print(F(", "));
    Serial.print(gy); Serial.print(F(", "));
    Serial.println(gz);
    Serial.print("FSR Reading: ");
    Serial.println(fsrValue);
    uploadToThingSpeak(lati, lon, ax, ay, az, gx, gy, gz);
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

// Upload data to ThingSpeak using HTTP GET via SIM800L
void uploadToThingSpeak(float lati, float lon, float ax, float ay, float az, float gx, float gy, float gz) {
  const char* THINGSPEAK_API_KEY = "GEOB8L3MARYBEO01"; // <-- Replace with your ThingSpeak Write API Key
  String url = String("http://api.thingspeak.com/update?api_key=") + THINGSPEAK_API_KEY +
               "&field1=" + String(lati, 6) +
               "&field2=" + String(lon, 6) +
               "&field3=" + String(ax, 6) +
               "&field4=" + String(ay, 6) +
               "&field5=" + String(az, 6) +
               "&field6=" + String(gx, 6) +
               "&field7=" + String(gy, 6) +
               "&field8=" + String(gz, 6);

  sendAT("AT+HTTPTERM");
  sendAT("AT+HTTPINIT");
  sendAT("AT+HTTPPARA=\"CID\",1");
  sim800l.print("AT+HTTPPARA=\"URL\",\""); sim800l.print(url); sim800l.println("\"");
  delay(100);
  sendAT("AT+HTTPACTION=0", 8000);  // 0 = GET
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
