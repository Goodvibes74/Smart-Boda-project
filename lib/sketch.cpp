#include <Wire.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <HardwareSerial.h>

//Pin Map
#define FSR_PIN     34
#define MPU_SDA     21
#define MPU_SCL     22
#define GSM_TX_PIN  17
#define GSM_RX_PIN  16
#define GPS_RX_PIN  4

Adafruit_MPU6050 mpu;
HardwareSerial GSM(2);
HardwareSerial GPS(1);

void sendGSM(const char *cmd, uint16_t wait = 500) {
  GSM.println(cmd);
  delay(wait);
  while (GSM.available()) {
    Serial.write(GSM.read());
  }
}

bool initSIM800() {
  Serial.println("Checking SIM800...");

  GSM.println("AT");
  delay(1000);
  if (GSM.find("OK")) {
    Serial.println("SIM800 responded.");
  } else {
    Serial.println("No response from SIM800.");
    return false;
  }

  sendGSM("ATE0");            // Echo off
  sendGSM("AT+CFUN=1");       // Full functionality
  sendGSM("AT+CPIN?");        // Check SIM status
  sendGSM("AT+CSQ");          // Signal quality
  sendGSM("AT+CREG?");        // Network registration

  Serial.println("Waiting for network...");
  int attempts = 0;
  while (attempts++ < 10) {
    GSM.println("AT+CREG?");
    delay(1000);
    if (GSM.find("+CREG: 0,1") || GSM.find("+CREG: 0,5")) {
      Serial.println("SIM800 is registered on network.");
      return true;
    }
    delay(1000);
  }

  Serial.println("Network registration failed.");
  return false;
}

void setup() {
  Serial.begin(115200);
  delay(1000);

  pinMode(FSR_PIN, INPUT);
  analogReadResolution(12); // Can be from 0–4095

  // THis isINITIALIZATION
  Serial.println("Initializing...");

  // I2C / MPU6050
  Wire.begin(MPU_SDA, MPU_SCL);
  if (!mpu.begin()) {
    Serial.println("MPU6050 not found!");
  }

  // GSM UART
  GSM.begin(9600, SERIAL_8N1, GSM_RX_PIN, GSM_TX_PIN);
  initSIM800();

  // GPS UART
  GPS.begin(9600, SERIAL_8N1, GPS_RX_PIN, -1);
}

float getBatteryVoltage() {
  // Voltage divider will be used with 10k and 20k resistors
  int rawValue = analogRead(FSR_PIN);
  float voltage = (rawValue / 4095.0) * 3.3;
  return voltage * (30.0 / 10.0);
}

float getBatteryPercentage() {
  float voltage = getBatteryVoltage();
  if (voltage < 3.0) return 0.0;
  if (voltage > 4.2) return 100.0;
  return (voltage - 3.0) / (4.2 - 3.0) * 100.0;
}

float checkCrash(){
    // Crash logic
    return 0.0;
}

float getCrashType() {
    // Crash type
    return 0.0; // Placeholder
}

float getCrashSeverity() {
    // Crash severity
    return 0.0; // Placeholder
}

float getCrashLocation() {
    // Crash location
    return 0.0; // Placeholder
}

float getCrashTime() {
    // Crash time
    return 0.0; // Placeholder
}

float getCrashSpeed() {
    // Crash speed
    return 0.0; // Placeholder
}

float getTopSpeed() {
    // Top speed logic
    return 0.0; // Placeholder
}

void loop() {
  int fsrValue = analogRead(FSR_PIN);
  Serial.print("FSR: "); Serial.println(fsrValue);

  sensors_event_t a, g, temp;
  mpu.getEvent(&a, &g, &temp);
  Serial.printf("Accel X: %.2f Y: %.2f Z: %.2f\n", a.acceleration.x, a.acceleration.y, a.acceleration.z);

  if (GPS.available()) {
    String gpsLine = GPS.readStringUntil('\n');
    Serial.print("GPS: "); Serial.println(gpsLine);
  }

  if (GSM.available()) {
    String gsmLine = GSM.readStringUntil('\n');
    Serial.print("GSM: "); Serial.println(gsmLine);
  }

  delay(1000);
}
