#include "Adafruit_Thermal.h"
#include "BlackBean.h"

#include "SoftwareSerial.h"
#define TX_PIN 6 // Arduino transmit  YELLOW WIRE  labeled RX on printer
#define RX_PIN 5 // Arduino receive   GREEN WIRE   labeled TX on printer

SoftwareSerial mySerial(RX_PIN, TX_PIN); // Declare SoftwareSerial obj first
Adafruit_Thermal printer(&mySerial,4);   

//--------------------------------------------- 

#define USE_ARDUINO_INTERRUPTS true
#include <PulseSensorPlayground.h>
const int OUTPUT_TYPE = SERIAL_PLOTTER;
const int PULSE_INPUT = A0;
PulseSensorPlayground pulseSensor;


void setup() {
   Serial.begin(115200);  //Sensor
   mySerial.begin(19200); //Printer

  pulseSensor.analogInput(PULSE_INPUT);
  pulseSensor.setSerial(Serial);
   
  printer.begin();
  printImg();

}

void loop() {
  int analogValue = analogRead(PULSE_INPUT);
  Serial.println(analogRead(A0));
  delay(500);
 pulseSensor.outputSample();
  if (pulseSensor.sawStartOfBeat()) {
   pulseSensor.outputBeat();
  }
}


void printImg(){
//      printer.println(F("             "));
      printer.printBitmap(BlackBean_width, BlackBean_height, BlackBean_data);

      }
