#include <Wire.h>
#include <SoftwareSerial.h>
#include <TinyGPS++.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>

/* ----------  forward prototypes  ---------- */
void sendAT(const char *cmd, uint32_t timeout = 2000);
void waitNetwork();
void setupGPRS();
void uploadToRealtimeDatabase(float lat, float lon, float ax, float ay, float az, float gx, float gy, float gz);
String getISOTime(); // helper for timestamp string
/* ------------------------------------------ */

// --- SIM800L -------------------------------------------------
#define SIM_RX_PIN 26
#define SIM_TX_PIN 27
#define FSR_PIN 35
SoftwareSerial sim800l(SIM_RX_PIN, SIM_TX_PIN);

// --- NEO -6M --------------------------------------------------
#define GPS_RX_PIN 34
#define GPS_TX_PIN 32
SoftwareSerial gpsSS(GPS_RX_PIN, GPS_TX_PIN);
TinyGPSPlus gps;

// --- MPU -6050 -----------------------------------------------
Adafruit_MPU6050 mpu;

// --- Firebase credentials ------------------------------------
const char *FIREBASE_PROJECT_ID = "safe-buddy-141a4";
const char *FIREBASE_API_KEY = "AIzaSyAkY6qkVOfuXhns81HwTICd41ts-LnBQ0Q";
const char *DATABASE_URL = "https://safe-buddy-141a4-default-rtdb.firebaseio.com/";
const char *DEVICE_ID = "device_001"; // Unique device ID

// --- Timing --------------------------------------------------
unsigned long lastUpload = 0;
const unsigned long UPLOAD_MS = 1000; // 100 ms

// -----------------------------------------------------------------
void setup()
{
  Serial.begin(115200);
  gpsSS.begin(9600);
  sim800l.begin(9600);
  pinMode(FSR_PIN, INPUT);

  Serial.println(F("Init MPU -6050…"));
  Wire.begin(21, 22); // Explicitly set I2C pins if not already
  Serial.println("Scanning I2C devices...");
  byte count = 0;
  for (byte address = 1; address < 127; ++address)
  {
    Wire.beginTransmission(address);
    if (Wire.endTransmission() == 0)
    {
      Serial.print("MPU-6050 found at 0x");
      Serial.println(address, HEX);
      count++;
    }
  }
  if (count == 0)
  {
    Serial.println("No I2C devices found.");
  }

  while (!mpu.begin())
  {
    Serial.println(F("MPU6050 not found. Retrying..."));
    delay(1000);
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
void loop()
{
  while (gpsSS.available())
    gps.encode(gpsSS.read());

  int fsrValue = analogRead(FSR_PIN);

  sensors_event_t a, g, temp;
  mpu.getEvent(&a, &g, &temp);

  if (millis() - lastUpload > UPLOAD_MS)
  {
    lastUpload = millis();

    /*if (gps.location.isValid()) {*/
    float lat = gps.location.lat();
    float lon = gps.location.lng();
    float ax = a.acceleration.x;
    float ay = a.acceleration.y;
    float az = a.acceleration.z;
    float gx = g.gyro.x;
    float gy = g.gyro.y;
    float gz = g.gyro.z;

    Serial.print(F("\u2192 Uploading: "));
    Serial.print(lat, 6);
    Serial.print(F(", "));
    Serial.print(lon, 6);
    Serial.print(F(", "));
    Serial.print(ax);
    Serial.print(F(", "));
    Serial.print(ay);
    Serial.print(F(", "));
    Serial.print(az);
    Serial.print(F(", "));
    Serial.print(gx);
    Serial.print(F(", "));
    Serial.print(gy);
    Serial.println(gz);
    Serial.print("FSR Reading: ");
    Serial.println(fsrValue);

    uploadToRealtimeDatabase(lat, lon, ax, ay, az, gx, gy, gz);
    /* } else {
       Serial.println(F("GPS not fixed yet"));
     }*/
  }
}

// --------------- Helper functions ------------------------------
void sendAT(const char *cmd, uint32_t timeout)
{
  sim800l.println(cmd);
  unsigned long t0 = millis();
  while (millis() - t0 < timeout)
  {
    while (sim800l.available())
      Serial.write(sim800l.read());
  }
}

void waitNetwork()
{
  Serial.println(F("Waiting network…"));
  while (true)
  {
    sim800l.println("AT+CREG?");
    unsigned long t0 = millis();
    String response = "";
    while (millis() - t0 < 2000)
    {
      while (sim800l.available())
      {
        char c = sim800l.read();
        response += c;
      }
    }

    Serial.print("Response: ");
    Serial.println(response);

    if (response.indexOf("+CREG: 0,1") != -1 || response.indexOf("+CREG: 0,5") != -1)
    {
      Serial.println("Network registered.");
      break;
    }

    Serial.print(".");
    delay(1000);
  }
}

void setupGPRS()
{
  Serial.println(F("GPRS attach…"));
  sendAT("AT+SAPBR=3,1,\"CONTYPE\",\"GPRS\"");
  sim800l.print(F("AT+SAPBR=3,1,\"APN\",\""));
  sim800l.print("internet");
  sim800l.println('"');
  sendAT("", 1500);
  sendAT("AT+SAPBR=1,1", 5000);
  sendAT("AT+SAPBR=2,1");
}

void uploadToRealtimeDatabase(float lat, float lon, float ax, float ay, float az, float gx, float gy, float gz)
{
  String url = String(DATABASE_URL) + "accident_detector/" + DEVICE_ID + ".json?auth=" + FIREBASE_API_KEY;

  String json = "{";
  json += "\"lat\": " + String(lat, 6) + ",";
  json += "\"lon\": " + String(lon, 6) + ",";
  json += "\"ax\": " + String(ax, 6) + ",";
  json += "\"ay\": " + String(ay, 6) + ",";
  json += "\"az\": " + String(az, 6) + ",";
  json += "\"gx\": " + String(gx, 6) + ",";
  json += "\"gy\": " + String(gy, 6) + ",";
  json += "\"gz\": " + String(gz, 6) + ",";
  json += "\"timestamp\": \"" + getISOTime() + "\"";
  json += "}";

  sendAT("AT+HTTPTERM");
  sendAT("AT+HTTPINIT");
  sendAT("AT+HTTPPARA=\"CID\",1");
  sim800l.print("AT+HTTPPARA=\"URL\",\"");
  sim800l.print(url);
  sim800l.println("\"");
  delay(100);
  sendAT("AT+HTTPPARA=\"CONTENT\",\"application/json\"");

  sim800l.print("AT+HTTPDATA=");
  sim800l.print(json.length());
  sim800l.println(",10000");
  delay(1000);
  sim800l.print(json);
  delay(1000);

  sendAT("AT+HTTPACTION=1", 8000); // POST
  sendAT("AT+HTTPREAD", 2000);
  sendAT("AT+HTTPTERM");
}

String getISOTime()
{
  if (gps.time.isValid() && gps.date.isValid())
  {
    char buf[25];
    sprintf(buf, "%04d-%02d-%02dT%02d:%02d:%02dZ",
            gps.date.year(), gps.date.month(), gps.date.day(),
            gps.time.hour(), gps.time.minute(), gps.time.second());
    return String(buf);
  }
  else
  {
    return "1970-01-01T00:00:00Z";
  }
}

/*#include <Wire.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <TinyGPS++.h>
#include <SoftwareSerial.h>
#include <math.h>

using namespace EspSoftwareSerial;

// --- Pin Definitions ---
#define SIM_RX 16
#define SIM_TX 17
#define GPS_RX 34
#define GPS_TX 32
#define FSR_PIN 35

// --- Object Instances ---
SoftwareSerial sim800l(SIM_RX, SIM_TX);
SoftwareSerial gpsSerial(GPS_RX, GPS_TX);
TinyGPSPlus gps;
Adafruit_MPU6050 mpu;

// --- Constants ---
const float GRAVITY = 9.80665;
const float ACCEL_SCALE = 4096.0;
const float GYRO_SCALE = 65.5;

const float ACCEL_THRESH = 24.5;
const float JERK_THRESH = 400.0;
const float GYRO_THRESH = 1.5;
const int FSR_THRESH = 500;
const unsigned long COOLDOWN = 5000;

// --- Globals ---
unsigned long lastCrash = 0;
float prevAx = 0, prevAy = 0, prevAz = 0;

const char *THINGSPEAK_KEY = "3Q5B2PR2LRKJUOE7";

// --- Function Prototypes ---
void sendAT(const char *cmd, uint32_t timeout = 2000);
void setupGPRS();
void waitNetwork();
void detectCrash(float, float, float, float, float, float, float, float, int, float);
void uploadToThingSpeak(float, float, float, float, float, float, float, float, int, String, float);

void setup()
{
  Serial.begin(115200);
  sim800l.begin(9600);
  gpsSerial.begin(9600);
  pinMode(FSR_PIN, INPUT);

  while (!mpu.begin())
  {
    Serial.println("MPU init failed...");
    delay(1000);
  }

  mpu.setAccelerometerRange(MPU6050_RANGE_8_G);
  mpu.setGyroRange(MPU6050_RANGE_500_DEG);
  mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);

  Serial.println("Sensors ready.");
  sendAT("AT");
  sendAT("AT+CPIN?");
  setupGPRS();
}

void loop()
{
  while (gpsSerial.available())
  {
    gps.encode(gpsSerial.read());
  }

  int fsr = analogRead(FSR_PIN);

  sensors_event_t a, g, temp;
  mpu.getEvent(&a, &g, &temp);

  float ax = a.acceleration.x;
  float ay = a.acceleration.y;
  float az = a.acceleration.z;

  float gx = g.gyro.x;
  float gy = g.gyro.y;
  float gz = g.gyro.z;

  float speed = gps.speed.kmph();

  float lat = gps.location.lat();
  float lon = gps.location.lng();

  Serial.printf("GPS: [Lat: %.6f, Lon: %.6f, Speed: %.1f km/h] | Accel: [X: %.2f, Y: %.2f, Z: %.2f] | Gyro: [X: %.2f, Y: %.2f, Z: %.2f] | FSR: %d\n",
                lat, lon, speed, ax, ay, az, gx, gy, gz, fsr);

  detectCrash(lat, lon, ax, ay, az, gx, gy, gz, fsr, speed);

  delay(500); // Loop delay
}

void detectCrash(float lat, float lon, float ax, float ay, float az, float gx, float gy, float gz, int fsr, float speed)
{
  if (millis() - lastCrash < COOLDOWN)
  {
    prevAx = ax;
    prevAy = ay;
    prevAz = az;
    return;
  }

  float aMag = sqrt(ax * ax + ay * ay + az * az);
  float prevMag = sqrt(prevAx * prevAx + prevAy * prevAy + prevAz * prevAz);
  float jerk = fabs(aMag - prevMag);
  float gMag = sqrt(gx * gx + gy * gy + gz * gz);

  bool crash = false;
  String severity = "None";

  if (aMag > ACCEL_THRESH || jerk > JERK_THRESH)
  {
    crash = true;
    severity = (aMag > 4 * GRAVITY) ? "High" : (aMag > 2.5 * GRAVITY) ? "Medium"
                                                                      : "Low";
  }

  if (gMag > GYRO_THRESH)
  {
    crash = true;
    if (severity == "None")
      severity = "Rollover";
    else if (severity == "Low")
      severity = "Medium";
    else if (severity == "Medium")
      severity = "High";
  }

  if (fsr > FSR_THRESH && crash)
  {
    if (severity == "Low")
      severity = "Medium";
  }

  if (crash)
  {
    Serial.println("Crash Detected!");
    uploadToThingSpeak(lat, lon, ax, ay, az, gx, gy, gz, fsr, severity, speed);
    lastCrash = millis();
  }

  prevAx = ax;
  prevAy = ay;
  prevAz = az;
}

void sendAT(const char *cmd, uint32_t timeout)
{
  sim800l.println(cmd);
  unsigned long start = millis();
  while (millis() - start < timeout)
  {
    while (sim800l.available())
      sim800l.read();
  }
}

void setupGPRS()
{
  sendAT("AT+SAPBR=3,1,\"CONTYPE\",\"GPRS\"");
  sim800l.print("AT+SAPBR=3,1,\"APN\",\"");
  sim800l.print("internet"); // Change this if your APN differs
  sim800l.println("\"");
  sendAT("", 1500);
  sendAT("AT+SAPBR=1,1", 5000);
  sendAT("AT+SAPBR=2,1");
}

void uploadToThingSpeak(float lat, float lon, float ax, float ay, float az, float gx, float gy, float gz, int fsr, String sev, float speed)
{
  String url = "https://api.thingspeak.com/update?api_key=" + String(THINGSPEAK_KEY);
  url += "&field1=" + String(lat, 6) + "," + String(lon, 6);
  url += "&field2=" + String(ax, 2) + "," + String(ay, 2) + "," + String(az, 2);
  url += "&field3=" + String(gx, 2) + "," + String(gy, 2) + "," + String(gz, 2);
  url += "&field4=" + String(fsr);
  url += "&field5=" + sev;
  url += "&field6=" + String(speed, 1);

  sendAT("AT+HTTPTERM");
  sendAT("AT+HTTPINIT");
  sendAT("AT+HTTPPARA=\"CID\",1");

  sim800l.print("AT+HTTPPARA=\"URL\",\"");
  sim800l.print(url);
  sim800l.println("\"");

  delay(100);
  sendAT("AT+HTTPACTION=0", 8000);
  sendAT("AT+HTTPREAD", 2000);
  sendAT("AT+HTTPTERM");
}*/
