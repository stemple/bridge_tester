#include "Adafruit_MotorShield.h"

int steps = 0; //Counter for number of steps completed by stepper motor

Adafruit_MotorShield AFMS = Adafruit_MotorShield();
Adafruit_StepperMotor *myMotor = AFMS.getStepper(200, 1);

void setup() {
  Serial.begin(9600);
  AFMS.begin();
  myMotor->setSpeed(20);
}

void loop() {
  if(Serial.available()){
    char message = Serial.read();
    /*
     * This loop is where the arduino will while running the stepper. All functions for reading
     * sensors will have to be within this loop as well.
     */
    while(message == 'F'){
      myMotor->step(1, FORWARD, DOUBLE); //Stepper will advance 1 step (360/200 = 1.8 deg/step) and advance steps counter
      steps = steps + 1;
      char temp = Serial.read();
      if(temp == 'X'){ //Reading for "halt" command & logging steps
        Serial.println(steps);
        break;
      }
    }
    /*
     * This is a reverse utility that can be used to set a specific position of the
     * motor when used with the forward loop
     */
    while(message == 'B'){
      myMotor->step(1, BACKWARD, SINGLE); //Stepper will reverse 1 step (360/200 = 1.8 deg/step) and regress steps counter
      steps = steps - 1;
      char temp = Serial.read();
      if(temp == 'X'){ //Reading for "halt" command & logging steps
        Serial.println(steps);
        break;
      }
    }
    /*
     * This is where the Arduino resets the stepper to its initial position, which will be determined by
     * how the bridge buster is built. Any other sensors and/or variables should also be reset here.
     */
    if(message == 'R'){
      myMotor->step(steps, BACKWARD, DOUBLE);
      steps = 0;
    }
    /*
     * This will set the step count to zero. Essentially sets the '0' position for the motor
     */
    if(message == 'Z'){
      steps = 0;
      Serial.println(steps);
    }
  }
}



