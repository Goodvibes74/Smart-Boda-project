#include <Wire.h>
#include <SoftwareSerial.h>
#include <TinyGPS++.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>

// --- FSR -------------------------------------------------
#define FSR_PIN 35
int fsrValue = 0;

// --- NEO‑6M --------------------------------------------------
#define GPS_RX_PIN 34
#define GPS_TX_PIN 32
SoftwareSerial gpsSS(GPS_RX_PIN, GPS_TX_PIN);
TinyGPSPlus  gps;

// --- MPU‑6050 -----------------------------------------------
Adafruit_MPU6050 mpu;

void setup() {
  Serial.begin(115200);

  gpsSS.begin(9600);

  mpu.begin();
  mpu.setAccelerometerRange(MPU6050_RANGE_8_G);
  mpu.setGyroRange(MPU6050_RANGE_500_DEG);
  mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);

  analogReadResolution(12);
  pinMode(FSR_PIN, INPUT);

}

void loop() {
  float lati = 0.0, lon = 0.0;
  float ax = 0.0, ay = 0.0, az = 0.0;
  float gx = 0.0, gy = 0.0, gz = 0.0;


  fsrValue = analogRead(FSR_PIN);

  sensors_event_t a, g, temp;
  mpu.getEvent(&a, &g, &temp);

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

  delay(500);

}
