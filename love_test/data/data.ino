#include "Adafruit_Thermal.h"
#include "printer_guacailogo.h"
#include "SoftwareSerial.h"
#define TX_PIN 6 // Arduino transmit  YELLOW WIRE  labeled RX on printer
#define RX_PIN 5 // Arduino receive   GREEN WIRE   labeled TX on printer

#define TX1_PIN 14 // Arduino transmit  YELLOW WIRE  labeled RX on printer
#define RX1_PIN 15 // Arduino receive   GREEN WIRE   labeled TX on printer

SoftwareSerial mySerial(RX_PIN, TX_PIN); // Declare SoftwareSerial obj first
SoftwareSerial logoSerial(RX1_PIN, TX1_PIN);
Adafruit_Thermal printer(&mySerial, 4);
Adafruit_Thermal logoPrinter(&logoSerial, 2);

//---------------------------------------------

#define USE_ARDUINO_INTERRUPTS true
#include <PulseSensorPlayground.h>
const int OUTPUT_TYPE = SERIAL_PLOTTER;
const int PULSE_INPUT = A0;
char incomingByte;
String sender;
String receiver;
boolean getReceiver;
boolean getSender;
boolean printing;

int pulseData[30];
int counter = 0;

PulseSensorPlayground pulseSensor;

void setup() {
  Serial.begin(115200);  //Sensor
  mySerial.begin(19200); //Printer
  logoSerial.begin(19200);

  pulseSensor.analogInput(PULSE_INPUT);
  pulseSensor.setSerial(Serial);
  printer.begin();
  logoPrinter.begin();
  getReceiver = false;
  getSender = false;
  printing = false;

}

void loop() {

  if (Serial.available() > 0) {
    // read the incoming byte:
    incomingByte = Serial.read();

    // if it is 0,  printer start to print
    if (incomingByte == 0) {
      printing = true;
      printLogo(sender);
    }
    //    end printing
    if (incomingByte == 1) {
      printer.println(F("  "));
      counter = 0;
      printing = false;
    }
    //    receiver sending
    else if (incomingByte == 2) {
      getReceiver = true;
      getSender = false;
    }
    //    sender sending
    else if (incomingByte == 3) {
      getReceiver = false;
      getSender = true;
    }

    //save receiver and sender name
    if (getReceiver) {
      receiver += incomingByte;
    } else if (getSender) {
      sender += incomingByte;
    }
    if (printing) {
      printer.justify('L');
      printer.inverseOn();
      int analogValue = analogRead(PULSE_INPUT);
      Serial.println(analogRead(A0));
      counter++;
      if (counter % 2 == 0 && counter <= 50) {
        pulseData[counter / 2] = analogValue;
        int temp = map(analogValue, 500, 1100, 1, 30);
        String tempString = "";
        for (int i = 0; i < temp; i++) {
          tempString += " ";
        }
        printer.println(tempString);

      }
      delay(500);
    }
    //    ------------------------------------------------
  }

}


void printLogo(String name) {
  //reformat the name--------------------------

  String newName  = "";
  for (int i = 0; i < name.length(); i++) {
    newName += name[i];
    newName += " ";
    if (i == name.length() - 1) {
      newName += ",";
    }
  }

  //  ------------------------------------------
  //name:
  logoPrinter.justify('C');
  logoPrinter.println(newName);

  //Thank you Message
  logoPrinter.doubleHeightOn();
  logoPrinter.setLineHeight(80);
  logoPrinter.boldOn();
  logoPrinter.println(F("T H A N K  Y O U"));
  logoPrinter.doubleHeightOff();
  logoPrinter.boldOff();
  logoPrinter.setLineHeight(50);
  logoPrinter.println(F("FOR PARTICIPATING."));
  logoPrinter.setLineHeight(50);


  //guacai logo
  logoPrinter.printBitmap(printer_guacailogo_width, printer_guacailogo_height, printer_guacailogo_data);

  //Ending:
  logoPrinter.println(F("Art Impact, Boston, 2019"));
  logoPrinter.println(F("(Feel free to take it with you)"));
  logoPrinter.println(F(" "));
  logoPrinter.println(F(" "));
  logoPrinter.println(F("------- Tear here -------"));
  logoPrinter.setLineHeight(80);
  logoPrinter.println(F(" "));
  sender = "";
  receiver = "";
}
