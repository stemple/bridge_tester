/*
 Example using the SparkFun HX711 breakout board with a scale
 By: Nathan Seidle
 SparkFun Electronics
 Date: November 19th, 2014
 License: This code is public domain but you buy me a beer if you use this and we meet someday (Beerware license).

 This example demonstrates basic scale output. See the calibration sketch to get the calibration_factor for your
 specific load cell setup.

 This example code uses bogde's excellent library: https://github.com/bogde/HX711
 bogde's library is released under a GNU GENERAL PUBLIC LICENSE

 The HX711 does one thing well: read load cells. The breakout board is compatible with any wheat-stone bridge
 based load cell which should allow a user to measure everything from a few grams to tens of tons.
 Arduino pin 2 -> HX711 CLK
 3 -> DAT
 5V -> VCC
 GND -> GND

 The HX711 board can be powered from 2.7V to 5V so the Arduino 5V power should be fine.

*/
#include <Wire.h>
#include "HX711.h"
#include <Adafruit_MotorShield.h>

// #2 = -43980
#define calibration_factor1 -43980.0 //This value is obtained using the SparkFun_HX711_Calibration sketch
#define calibration_factor2 -41520.0 //This value is obtained using the SparkFun_HX711_Calibration sketch
#define calibration_factor3 -44280.0 //This value is obtained using the SparkFun_HX711_Calibration sketch
#define calibration_factor4 -44580.0 //This value is obtained using the SparkFun_HX711_Calibration sketch

// load sensor 1
#define DOUT1  10
#define CLK1  11
// load sensor 2
#define DOUT2 3
#define CLK2  2
// load sensor 3
#define DOUT3  9
#define CLK3  8
// load sensor 4
#define DOUT4  4
#define CLK4  5

HX711 scale1(DOUT1, CLK1);
HX711 scale2(DOUT2, CLK2);
HX711 scale3(DOUT3, CLK3);
HX711 scale4(DOUT4, CLK4);

float loadVals[] = {0,0,0,0};
char message;
int steps = 0; //Counter for number of steps completed by stepper motor

Adafruit_MotorShield AFMS = Adafruit_MotorShield();
Adafruit_StepperMotor *myMotor = AFMS.getStepper(200, 1);

void setup() {
  Serial.begin(9600);
  AFMS.begin();
  myMotor->setSpeed(20);

  scale1.set_scale(calibration_factor1); //This value is obtained by using the SparkFun_HX711_Calibration sketch
  scale2.set_scale(calibration_factor2); //This value is obtained by using the SparkFun_HX711_Calibration sketch
  scale3.set_scale(calibration_factor3); //This value is obtained by using the SparkFun_HX711_Calibration sketch
  scale4.set_scale(calibration_factor4); //This value is obtained by using the SparkFun_HX711_Calibration sketch
  scale1.tare();  //Assuming there is no weight on the scale at start up, reset the scale to 0
  scale2.tare();  //Assuming there is no weight on the scale at start up, reset the scale to 0
  scale3.tare();  //Assuming there is no weight on the scale at start up, reset the scale to 0
  scale4.tare();  //Assuming there is no weight on the scale at start up, reset the scale to 0
}

void loop() {
  if(Serial.available()){
    message = Serial.read();
  }

    if(message == 'p' || message == 'x'){
        //Serial.println(steps);
        // Just stop.
    } else if (message == 's'){
      // Run the motor forward, read sensor values and then write to the serial port
      myMotor->step(1, BACKWARD, DOUBLE);
      //Stepper will advance 1 step (360/200 = 1.8 deg/step) and advance steps counter
      steps = steps + 1;

      // Read the load sensor values
      loadVals[0] = scale1.get_units();
      loadVals[1] = scale2.get_units();
      loadVals[2] = scale3.get_units();
      loadVals[3] = scale4.get_units();

      // for testing
      //loadVals[0] = random(0,1000);
      //loadVals[1] = random(0,1000);
      //loadVals[2] = random(0,1000);
      //loadVals[3] = random(0,1000);

      // Using serial communication, send these values.
      Serial.print(loadVals[0]);
      Serial.print(",");
      Serial.print(loadVals[1]);
      Serial.print(",");
      Serial.print(loadVals[2]);
      Serial.print(",");
      Serial.println(loadVals[3]);
    } else if (message == 'b'){
      // Go backwards
      myMotor->step(1, FORWARD, SINGLE); //Stepper will reverse 1 step (360/200 = 1.8 deg/step) and regress steps counter
      steps = steps - 1;
    } else if(message == 'r'){
      // Go forwards
      myMotor->step(steps, FORWARD, DOUBLE);
      steps = 0;
    } else if(message == 'z'){
      // Reset the counter (for purposes of "zeroing" the stepper
      steps = 0;
      //Serial.println(steps);
    }

    // Not sure what value is best here for a delay?
    delay(10);
  }
