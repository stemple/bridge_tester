#include <HX711.h>

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

// 1 (6, 7) is 430000
// 2 (2, 3) is 420000
// 3 (8, 9) is 450000
// 4 (4, 5) is 420000

#define calibration_factor1 430000.0 //This value is obtained using the SparkFun_HX711_Calibration sketch
#define calibration_factor2 420000.0 //This value is obtained using the SparkFun_HX711_Calibration sketch
#define calibration_factor3 450000.0 //This value is obtained using the SparkFun_HX711_Calibration sketch
#define calibration_factor4 420000.0 //This value is obtained using the SparkFun_HX711_Calibration sketch

// load sensor 1
#define DOUT1  6
#define CLK1  7
// load sensor 2
#define DOUT2 2
#define CLK2  3
// load sensor 3
#define DOUT3  8
#define CLK3  9
// load sensor 4
#define DOUT4  4
#define CLK4  5

HX711 scale1;
HX711 scale2;
HX711 scale3;
HX711 scale4;


float loadVals[] = {0,0,0,0};
char message;
int steps = 0; //Counter for number of steps completed by stepper motor
boolean paused = false;
boolean started = false;
boolean stopped = true;
boolean reversed = false;

//Adafruit_MotorShield AFMS = Adafruit_MotorShield();
//Adafruit_StepperMotor *myMotor = AFMS.getStepper(200, 1);

void setup() {
  Serial.begin(9600);
  //AFMS.begin();
  //myMotor->setSpeed(20);

  scale1.begin(DOUT1, CLK1);
  scale2.begin(DOUT2, CLK2);
  scale3.begin(DOUT3, CLK3);
  scale4.begin(DOUT4, CLK4);

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
    if (message == 'p') {
    paused = !paused;
  } else if (message == 's') {
    started = true;
    stopped = false;
    paused = false;
    reversed = false;
  } else if (message == 'x') {
    started = false;
    stopped = true;
    paused = false;
    reversed = false;
  } else if (message == 'b') {
    started = false;
    stopped = false;
    paused = false;
    reversed = true;
  }
  }

  if( paused || stopped){
        //Serial.println(steps);
        // Just stop.
   } else if (started){
      // Run the motor forward, read sensor values and then write to the serial port
      //myMotor->setSpeed(20);
      //myMotor->step(2, BACKWARD, DOUBLE);
      //Stepper will advance 1 step (360/200 = 1.8 deg/step) and advance steps counter
      //steps = steps + 2;

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
      Serial.println();
    } else if (reversed){
      // Go backwards
      Serial.println("Going backwards");
      //myMotor->setSpeed(200); // Faster speed t reverse
      //myMotor->step(2, FORWARD, SINGLE); //Stepper will reverse 2 steps (360/200 = 1.8 deg/step) and regress steps counter
      //steps = steps - 20;
    }

    // Not sure what value is best here for a delay?
    //delay(1000);
    delay(10);
  }
