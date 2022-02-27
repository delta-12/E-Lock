/*
 * Author:                Benjamin Esquieres (btesq235@gmail.com | bte12@pitt.edu)
 * Acknowledgements:      Rob Kerr (mail@robkerr.com) 
 * Description:           POC for Bluetooth Kensignton Lock
 */
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

#define PERIPHERAL_NAME             "Bluetooth Lock"
#define SERVICE_UUID                "ef27b905-9bfc-41cd-9e6f-847165c6451e"
#define CHARACTERISTIC_INPUT_UUID   "29bbc3ed-6faa-4011-b42e-823d518fa2e4"
#define CHARACTERISTIC_OUTPUT_UUID  "54881514-684c-4457-8aee-b4e2a1acb6bf"

int armed = 0;
const int LED = 22;

// test vibration
int vibr;
const int vibrTest = 21;

// Current value of output characteristic persisted here
static uint8_t outputData[2];

// Output characteristic is used to send the response back to the connected phone
BLECharacteristic *pOutputRes;

// Send notifications to connected phone
void blOutput() {
  Serial.printf("Sending response:   %02x %02x\r\n", outputData[0], outputData[1]);  
        
  pOutputRes->setValue((uint8_t *)outputData, 2);
  pOutputRes->notify();
}

// Class defines methods called when a device connects and disconnects from the service
class ServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
        Serial.println("BLE Client Connected");
    }
    void onDisconnect(BLEServer* pServer) {
        BLEDevice::startAdvertising();
        Serial.println("BLE Client Disconnected");
    }
};

class InputReceivedCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharWriteState) {
        uint8_t *inputValues = pCharWriteState->getData();

        Serial.printf("Receiving:   %02x %02x\r\n", inputValues[0], inputValues[1]);
        if (inputValues[0] == 0x00) {
          switch(inputValues[1]) {
            case 0x00: // disarm
              armed = 0;
              Serial.printf("Disarmed\r\n");
              outputData[1] = 0x00;
              break;
            case 0x01: // arm
              armed = 1;
              Serial.printf("Armed\r\n");
              outputData[1] = 0x01;
              break;
            default:
              Serial.printf("Unknown command\r\n");  
              outputData[1] = 0x02;  
              break;
          }
        }
        
        outputData[0] = 0x00;
        blOutput();
    }
};

void setup() {
  // Use the Arduino serial monitor set to this baud rate to view BLE peripheral logs 
  Serial.begin(115200);
  Serial.println("Begin Setup BLE Service and Characteristics");

  // set pin for indicator LED as output, vibrTest as input
  pinMode(LED, OUTPUT);
  pinMode(vibrTest, INPUT);

  // Configure thes server

  BLEDevice::init(PERIPHERAL_NAME);
  BLEServer *pServer = BLEDevice::createServer();

  // Create the service
  BLEService *pService = pServer->createService(SERVICE_UUID);

  // Create a characteristic for the service
  BLECharacteristic *pInputChar = pService->createCharacteristic(
                              CHARACTERISTIC_INPUT_UUID,                                        
                              BLECharacteristic::PROPERTY_WRITE_NR | BLECharacteristic::PROPERTY_WRITE);

  pOutputRes = pService->createCharacteristic(
                              CHARACTERISTIC_OUTPUT_UUID,
                              BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY);

                                       

  // Hook callback to report server events
  pServer->setCallbacks(new ServerCallbacks());
  pInputChar->setCallbacks(new InputReceivedCallbacks());

  // Initial characteristic value
  outputData[0] = 0x00;
  pOutputRes->setValue((uint8_t *)outputData, 1);

  // Start the service
  pService->start();

  // Advertise the service
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);  
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();

  Serial.println("BLE Service is advertising");
}

void loop() {
  digitalWrite(LED, armed);
  vibr = digitalRead(vibrTest);
  if (armed == 1 && vibr == 1) {
    Serial.println("Vibration detected!");
    outputData[0] = 0x01;
    outputData[1] = 0x01;
    blOutput();
  }
  delay(200);
}
