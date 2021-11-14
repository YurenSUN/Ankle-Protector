#include <ArduinoBLE.h>

static const char* greeting = "BLE Greeting";
BLEService sensorService("180C");  // User defined service
BLEStringCharacteristic sensorCharacteristic("2A56",  // standard 16-bit characteristic UUID
    BLERead, 13); // remote clients will only be able to read this

//Right flex
const int flexPinR = A0;

//Right force
const int forcePinR = A6;


void setup() {
  // initialize serial communication at 9600 bits per second:
  Serial.begin(9600);
  // Only connect when using serial monitor
//  while (!Serial);

  pinMode(LED_BUILTIN, OUTPUT); // initialize the built-in LED pin

  if (!BLE.begin()) {   // initialize BLE
    Serial.println("starting BLE failed!");
    while (1);
  }

  BLE.setLocalName("Nano33BLE");  // Set name for connection
  BLE.setAdvertisedService(sensorService); // Advertise service
  sensorService.addCharacteristic(sensorCharacteristic); // Add characteristic to service
  BLE.addService(sensorService); // Add service
  sensorCharacteristic.setValue(greeting); // Set greeting string

  BLE.advertise();  // Start advertising
  Serial.print("Peripheral device MAC: ");
  Serial.println(BLE.address());
  Serial.println("Waiting for connections...");
}

void loop() {
  BLEDevice central = BLE.central();  // Wait for a BLE central to connect

  // if a central is connected to the peripheral:
  if (central) {
    Serial.print("Connected to central MAC: ");
    // print the central's BT address:
    Serial.println(central.address());
    // turn on the LED to indicate the connection:
    digitalWrite(LED_BUILTIN, HIGH);

    while (central.connected()){
      // read the value from the sensor:
      int flexValueR = analogRead(flexPinR);
      int forceValueR = analogRead(forcePinR);

      // print out the value you read:
      String valuesToSend = String(flexValueR) + ","
        + String(forceValueR);
      
      Serial.println(valuesToSend);
      sensorCharacteristic.writeValue(valuesToSend);

      // delay in between reads for stability
      delay(100);   
    }
    
    // when the central disconnects, turn off the LED:
    digitalWrite(LED_BUILTIN, LOW);
    Serial.print("Disconnected from central MAC: ");
    Serial.println(central.address());
  }
  

}
