#include <Wire.h>
#include <TinyGPS++.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>

// Define pins
#define MPU_SDA 21
#define MPU_SCL 22

#define SIM800_RX 16
#define SIM800_TX 17

#define GPS_RX 34
#define GPS_TX 32

// Serial interfaces
HardwareSerial sim800(1);     // SIM800L
HardwareSerial gpsSerial(2);  // GPS module

TinyGPSPlus gps;
Adafruit_MPU6050 mpu;

void setup() {
  Serial.begin(115200);
  delay(2000);
  Serial.println("Starting...");

  // SIM800L
  sim800.begin(9600, SERIAL_8N1, SIM800_RX, SIM800_TX);
  Serial.println("SIM800L serial started");

  // GPS
  gpsSerial.begin(9600, SERIAL_8N1, GPS_RX, GPS_TX);
  Serial.println("GPS serial started");

  // MPU6050
  Wire.begin(MPU_SDA, MPU_SCL);
  if (!mpu.begin()) {
    Serial.println("Failed to find MPU6050 chip");
    while (1) delay(10);
  }
  Serial.println("MPU6050 found!");

  mpu.setAccelerometerRange(MPU6050_RANGE_8_G);
  mpu.setGyroRange(MPU6050_RANGE_500_DEG);
  mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);
  Serial.println("MPU6050 configured");

  // Basic AT check for SIM800
  sim800.println("AT");
  delay(1000);
  readSimResponse();
}

void loop() {
  // Read acceleration
  sensors_event_t a, g, temp;
  mpu.getEvent(&a, &g, &temp);
  Serial.print("Accel X: "); Serial.print(a.acceleration.x);
  Serial.print(" Y: "); Serial.print(a.acceleration.y);
  Serial.print(" Z: "); Serial.println(a.acceleration.z);

  // Read GPS
  while (gpsSerial.available()) {
    gps.encode(gpsSerial.read());
  }

  if (gps.location.isUpdated()) {
    Serial.print("Latitude: "); Serial.println(gps.location.lat(), 6);
    Serial.print("Longitude: "); Serial.println(gps.location.lng(), 6);
  } else {
    Serial.println("Waiting for GPS fix...");
  }

  // Read SIM800 responses
  while (sim800.available()) {
    String resp = sim800.readStringUntil('\n');
    resp.trim();
    if (resp.length()) {
      Serial.print("SIM800: ");
      Serial.println(resp);
    }
  }

  delay(2000);
}

void readSimResponse() {
  unsigned long timeout = millis();
  while (millis() - timeout < 3000) {
    if (sim800.available()) {
      String line = sim800.readStringUntil('\n');
      line.trim();
      if (line.length()) {
        Serial.print("SIM800: ");
        Serial.println(line);
      }
    }
  }
}
