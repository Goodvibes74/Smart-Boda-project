#include <Wire.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <TinyGPS++.h>

// --------- Function Prototypes ---------
void sendGSM(String command);
void getGPS();
void getAccelerometer();
void sendToThingSpeak(String payload);

// --------- Pin Definitions ---------
#define GPS_RX 32
#define GPS_TX 34
#define GSM_RX 17
#define GSM_TX 16

// --------- Serial Interfaces ---------
// Use available hardware serial ports
HardwareSerial gpsSerial(1); // UART1
HardwareSerial gsmSerial(2); // UART2

// --------- Global Variables ---------
Adafruit_MPU6050 mpu;
TinyGPSPlus gps;

float latitude = 0;
float longitude = 0;
float ax, ay, az;

// --------- Setup ---------
void setup() {
  Serial.begin(115200);
  Wire.begin();

  gpsSerial.begin(9600, SERIAL_8N1, GPS_RX, GPS_TX);
  Serial.println("GPS Serial started");

  gsmSerial.begin(9600, SERIAL_8N1, GSM_RX, GSM_TX);
  Serial.println("GSM Serial started");

  // Initialize MPU6050
  if (!mpu.begin()) {
    Serial.println("Failed to find MPU6050 chip");
    while (1);
  }
  Serial.println("MPU6050 Found!");

  delay(2000);

  // Setup GSM Internet
  sendGSM("AT");
  sendGSM("AT+CSQ");
  sendGSM("AT+SAPBR=3,1,\"CONTYPE\",\"GPRS\"");
  sendGSM("AT+SAPBR=3,1,\"APN\",\"internet\""); // Use your SIM's APN
  sendGSM("AT+SAPBR=1,1");
}

// --------- Main Loop ---------
void loop() {
  getGPS();
  getAccelerometer();

  String payload = "field1=" + String(ax) +
                   "&field2=" + String(ay) +
                   "&field3=" + String(az) +
                   "&field4=" + String(latitude, 6) +
                   "&field5=" + String(longitude, 6);

  sendToThingSpeak(payload);
  delay(15000); // ThingSpeak requires 15 sec interval
}

// --------- Get GPS Location ---------
void getGPS() {
  unsigned long start = millis();
  while (millis() - start < 2000) {
    while (gpsSerial.available()) {
      gps.encode(gpsSerial.read());
    }
  }

  if (gps.location.isValid()) {
    latitude = gps.location.lat();
    longitude = gps.location.lng();
    Serial.print("Latitude: ");
    Serial.println(latitude, 6);
    Serial.print("Longitude: ");
    Serial.println(longitude, 6);
  } else {
    Serial.println("Waiting for valid GPS fix...");
  }
}

// --------- Read MPU6050 Acceleration ---------
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

// --------- Send AT Commands to GSM ---------
void sendGSM(String command) {
  gsmSerial.println(command);
  delay(1000);
  while (gsmSerial.available()) {
    Serial.write(gsmSerial.read());
  }
}

// --------- Send Data to ThingSpeak ---------
void sendToThingSpeak(String payload) {
  sendGSM("AT+HTTPINIT");
  sendGSM("AT+HTTPPARA=\"CID\",1");
  sendGSM("AT+HTTPPARA=\"URL\",\"http://api.thingspeak.com/update?api_key=GEOB8L3MARYBEO01&" + payload + "\"");
  sendGSM("AT+HTTPACTION=0");
  delay(1000);
  sendGSM("AT+HTTPTERM");
}
