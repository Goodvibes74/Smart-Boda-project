#include <SoftwareSerial.h>

// Define the RX and TX pins for SoftwareSerial
// GPIO34 is an input-only pin on the ESP32, so it can only be used as RX.
// You'll need to choose another suitable GPIO for TX if you need bidirectional communication.
// For this example, we'll use GPIO32 as TX for demonstration purposes.
#define RX_PIN 34 // GPIO34 connected to the TX of the external device
#define TX_PIN 32 // GPIO32 connected to the RX of the external device (can be any suitable output pin)

// Create a SoftwareSerial object
// The parameters are (RX_PIN, TX_PIN)
SoftwareSerial esp32Serial(RX_PIN, TX_PIN);

void setup() {
  // Initialize hardware serial for debugging (optional)
  Serial.begin(115200);
  Serial.println("ESP32 SoftwareSerial Test");
  Serial.print("Using RX_PIN: ");
  Serial.println(RX_PIN);
  Serial.print("Using TX_PIN: ");
  Serial.println(TX_PIN);

  // Initialize SoftwareSerial at your desired baud rate
  esp32Serial.begin(9600); // Common baud rates: 9600, 19200, 38400, 57600, 115200
  Serial.println("SoftwareSerial initialized at 9600 baud.");
}

void loop() {
  // Read data from SoftwareSerial (from the external device)
  if (esp32Serial.available()) {
    char receivedChar = esp32Serial.read();
    Serial.print("Received via SoftwareSerial: ");
    Serial.println(receivedChar);

    // Echo the received character back (optional, for testing)
    esp32Serial.print("Echo: ");
    esp32Serial.println(receivedChar);
  }

  // Send data from ESP32 to the external device via SoftwareSerial
  // This part is just for demonstration and will send "Hello!" every 5 seconds.
  static unsigned long lastSendTime = 0;
  if (millis() - lastSendTime > 5000) { // Send every 5 seconds
    esp32Serial.println("Hello from ESP32!");
    Serial.println("Sent 'Hello from ESP32!' via SoftwareSerial.");
    lastSendTime = millis();
  }

  // You can also read from the hardware serial (if connected to your computer)
  // and send it out via SoftwareSerial.
  if (Serial.available()) {
    char charFromSerial = Serial.read();
    esp32Serial.print("From PC: ");
    esp32Serial.println(charFromSerial);
    Serial.print("Sent '");
    Serial.print(charFromSerial);
    Serial.println("' from PC to external device.");
  }

  delay(1000); // Small delay to prevent busy-waiting
}
