#include <Wire.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <SoftwareSerial.h>

#define GPS_RX 32  // GPS TX to ESP32 RX
#define GPS_TX 34  // GPS RX to ESP32 TX
#define GSM_RX 17  // GSM TX to ESP32 RX
#define GSM_TX 16  // GSM RX to ESP32 TX

SoftwareSerial gpsSerial(GPS_RX, GPS_TX);
SoftwareSerial gsmSerial(GSM_RX, GSM_TX);

Adafruit_MPU6050 mpu;

String gpsData = "";
float ax, ay, az;

void setup() {
  Serial.begin(115200);
  Wire.begin();

  // Initialize GPS
  gpsSerial.begin(9600);
  Serial.println("GPS Serial started");

  // Initialize GSM
  gsmSerial.begin(9600);
  Serial.println("GSM Serial started");

  // Initialize MPU6050
  if (!mpu.begin()) {
    Serial.println("Failed to find MPU6050 chip");
    while (1);
  }
  Serial.println("MPU6050 Found!");

  delay(2000);
  sendGSM("AT"); // Init check
  sendGSM("AT+CSQ"); // Signal quality
  sendGSM("AT+SAPBR=3,1,\"CONTYPE\",\"GPRS\"");
  sendGSM("AT+SAPBR=3,1,\"APN\",\"internet\""); // Use your GSM carrier APN
  sendGSM("AT+SAPBR=1,1"); // Open bearer
}

void loop() {
  getGPS();
  getAccelerometer();

  String payload = "field1=" + String(ax) + "&field2=" + String(ay) +
                   "&field3=" + String(az) + "&field4=" + gpsData;

  sendToThingSpeak(payload);

  delay(15000); // ThingSpeak limit: 15s
}

void getGPS() {
  gpsData = "";
  unsigned long startTime = millis();
  while (millis() - startTime < 2000) {
    if (gpsSerial.available()) {
      char c = gpsSerial.read();
      gpsData += c;
    }
  }

  // Optionally, parse NMEA sentences here if needed
  Serial.println("GPS Raw Data:");
  Serial.println(gpsData);
}

void getAccelerometer() {
  sensors_event_t a, g, temp;
  mpu.getEvent(&a, &g, &temp);

  ax = a.acceleration.x;
  ay = a.acceleration.y;
  az = a.acceleration.z;

  Serial.println("Acceleration:");
  Serial.print("X: "); Serial.println(ax);
  Serial.print("Y: "); Serial.println(ay);
  Serial.print("Z: "); Serial.println(az);
}

void sendGSM(String command) {
  gsmSerial.println(command);
  delay(1000);
  while (gsmSerial.available()) {
    Serial.write(gsmSerial.read());
  }
}

void sendToThingSpeak(String payload) {
  sendGSM("AT+HTTPINIT");
  sendGSM("AT+HTTPPARA=\"CID\",1");
  sendGSM("AT+HTTPPARA=\"URL\",\"http://api.thingspeak.com/update?api_key= "GEOB8L3MARYBEO01" + payload + "\"");
  sendGSM("AT+HTTPACTION=0");

  delay(1000);
  sendGSM("AT+HTTPTERM");
}
