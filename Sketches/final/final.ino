#include <Wire.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <TinyGPS.h>

//////////////////// USER CONFIG ////////////////////
#define MPU_SDA        21
#define MPU_SCL        22

#define GPS_RX_PIN     34   // ESP32 RX  (connected to NEO TX)
#define GPS_TX_PIN     32   // ESP32 TX  (connected to NEO RX)

#define SIM_RX_PIN     16   // ESP32 RX  (connected to SIM TX)
#define SIM_TX_PIN     17   // ESP32 TX  (connected to SIM RX)
#define SIM_RST_PIN     4   // optional, tie to RST pin on SIM800L

const char* APN               = "internet";          // SIM provider APN
const char* THINGSPEAK_APIKEY = "GEOB8L3MARYBEO01"; // ThingSpeak write key

const uint32_t POST_INTERVAL_MS   = 15000; // ≥15 s for ThingSpeak
const uint32_t SIM_RETRY_MS       = 30000; // retry SIM init every 30 s
const uint32_t MPU_RETRY_MS       = 15000; // retry MPU init every 15 s
//////////////////////////////////////////////////////

HardwareSerial Sim800(2);  // UART2 ⇒ SIM800L
HardwareSerial GpsUart(1); // UART1 ⇒ GPS

Adafruit_MPU6050 mpu;
TinyGPS          gps;

// State flags
bool   mpuOK  = false;
bool   simOK  = false;
uint32_t lastSimAttempt = 0;
uint32_t lastMpuAttempt = 0;
uint32_t lastPost       = 0;
float   latitude  = 0.0;
float   longitude = 0.0;
uint8_t sats      = 0;

// ───────────────── UTILS ─────────────────
void log(const char* tag, const char* msg) {
  Serial.print(tag);
  Serial.println(msg);
}

String readSimResponse(uint32_t timeoutMs = 1000) {
  String resp;
  uint32_t start = millis();
  while (millis() - start < timeoutMs) {
    while (Sim800.available()) resp += (char)Sim800.read();
    delay(2);
  }
  return resp;
}

bool sendAT(const String& cmd, uint32_t timeoutMs = 2000) {
  Serial.print(F("[SIM=>] ")); Serial.println(cmd);
  Sim800.println(cmd);
  String resp = readSimResponse(timeoutMs);
  Serial.print(F("[SIM<=] ")); Serial.println(resp);
  return resp.indexOf("OK") != -1 || resp.indexOf("CONNECT") != -1;
}

bool initSIM800() {
  log("[SIM] ", "Initializing…");
  if (!sendAT("AT", 2000))                         return false;
  sendAT("ATE0");                                  // echo off
  if (!sendAT("AT+CPIN?"))                        return false;
  if (!sendAT("AT+CREG?"))                        return false;
  sendAT("AT+CGATT=1", 5000);                      // attach GPRS (non-fatal)

  sendAT("AT+SAPBR=3,1,\"CONTYPE\",\"GPRS\"");
  sendAT(String("AT+SAPBR=3,1,\"APN\",\"")+APN+"\"");
  if (!sendAT("AT+SAPBR=1,1", 7000))             return false; // open bearer
  sendAT("AT+SAPBR=2,1");

  sendAT("AT+HTTPTERM"); // non-fatal if not yet initialized
  if (!sendAT("AT+HTTPINIT"))                     return false;

  log("[SIM] ", "Ready ✔");
  return true;
}

bool httpGET(const String& url) {
  if (!simOK) return false;
  log("[HTTP] ", "GET → ThingSpeak");
  if (!sendAT(String("AT+HTTPPARA=\"URL\",\"")+url+"\"")) return false;
  if (!sendAT("AT+HTTPACTION=0", 8000))                   return false;
  sendAT("AT+HTTPREAD", 2000); // dump response (ignores success)
  return true;
}

bool initMPU() {
  log("[MPU] ", "Detecting…");
  if (mpu.begin()) {
    mpu.setAccelerometerRange(MPU6050_RANGE_8_G);
    mpu.setGyroRange(MPU6050_RANGE_500_DEG);
    mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);
    log("[MPU] ", "Initialized ✔");
    return true;
  }
  log("[MPU] ", "NOT FOUND ❌ (will retry)");
  return false;
}

// ───────────────── SETUP ─────────────────
void setup() {
  Serial.begin(115200);
  delay(200);
  Serial.println();
  Serial.println(F("===== ESP32 ThingSpeak Uploader (Robust) ====="));

  Wire.begin(MPU_SDA, MPU_SCL);
  mpuOK = initMPU();

  GpsUart.begin(9600, SERIAL_8N1, GPS_RX_PIN, GPS_TX_PIN);
  log("[GPS] ", "UART started ✔ (9600)");

  Sim800.begin(9600, SERIAL_8N1, SIM_RX_PIN, SIM_TX_PIN);
  pinMode(SIM_RST_PIN, OUTPUT);
  digitalWrite(SIM_RST_PIN, HIGH);
  log("[SIM] ", "UART started ✔ (9600)");

  lastSimAttempt = millis();
  simOK = initSIM800();
}

// ───────────────── LOOP ─────────────────
void loop() {
  while (GpsUart.available()) gps.encode(GpsUart.read());
  float latTmp, lonTmp;
  gps.f_get_position(&latTmp, &lonTmp);
  if (latTmp != TinyGPS::GPS_INVALID_F_ANGLE) {
    latitude = latTmp;
    longitude = lonTmp;
    sats = gps.satellites();
  }
  static uint32_t gpsLast = 0;
  if (millis() - gpsLast > 1000) {
    gpsLast = millis();
    Serial.printf("[GPS] lat=%.6f lon=%.6f sats=%u\n", latitude, longitude, sats);
  }

  if (!mpuOK && millis() - lastMpuAttempt > MPU_RETRY_MS) {
    lastMpuAttempt = millis();
    mpuOK = initMPU();
  }

  if (!simOK && millis() - lastSimAttempt > SIM_RETRY_MS) {
    lastSimAttempt = millis();
    digitalWrite(SIM_RST_PIN, LOW);  delay(200);  digitalWrite(SIM_RST_PIN, HIGH);
    simOK = initSIM800();
  }

  if (millis() - lastPost >= POST_INTERVAL_MS) {
    lastPost = millis();

    if (latitude == 0.0 && longitude == 0.0) {
      Serial.println(F("[GPS] Invalid fix – skipping ThingSpeak update"));
      return;
    }

    float ax = 0, ay = 0, az = 0;
    if (mpuOK) {
      sensors_event_t a, g, t;
      if (mpu.getEvent(&a, &g, &t)) {
        ax = a.acceleration.x;
        ay = a.acceleration.y;
        az = a.acceleration.z;
        Serial.printf("[MPU] ax=%.2f ay=%.2f az=%.2f\n", ax, ay, az);
      } else {
        Serial.println(F("[MPU] Read failed – resetting module"));
        mpuOK = false;
      }
    } else {
      Serial.println(F("[MPU] Data unavailable"));
    }

    String url = String("http://api.thingspeak.com/update?api_key=") + THINGSPEAK_APIKEY;
    url += "&field1=" + String(ax, 2);
    url += "&field2=" + String(ay, 2);
    url += "&field3=" + String(az, 2);
    url += "&field4=" + String(latitude, 6);
    url += "&field5=" + String(longitude, 6);

    if (!httpGET(url)) {
      Serial.println(F("[HTTP] Send failed – will retry next cycle"));
      simOK = false;
    }
  }
}
