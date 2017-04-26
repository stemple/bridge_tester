/* 
 This software reads from an Arduino serially, which is reading out four
 load sensors for testing model bridges.
 
 This code is modified from a tutorial by Elaine Laguerta (http://url/of/online/tutorial.cc)
 
 */

import processing.serial.*;

Serial myPort; //creates a software serial port on which you will listen to Arduino
PFont font;
Table table = new Table(); //table where we will read in and store values. You can name it something more creative!

int numReadings = 10; //keeps track of how many readings you'd like to take before writing the file. 
int readingCounter = 0; //counts each reading to compare to numReadings. 

float loadGoal1 = 49;
float loadGoal2 = 98;

float totalLoad;

boolean goal1 = false;
boolean goal2 = false;

String fileName;
String val;
boolean start = false;
boolean pause = false;
int fileCounter = 0;

// for debugging
float debugLoad = 0;

void setup()
{
  font = createFont("Courier", 30);
  textFont(font);
  
  String ports[] = Serial.list();
  String portName = Serial.list()[3];
  for (int i = 0; i < ports.length; i++) {
    println(ports[i]);
  }
  //CAUTION: your Arduino port number is probably different! Mine happened to be 1. Use a "handshake" sketch to figure out and test which port number your Arduino is talking on. A "handshake" establishes that Arduino and Processing are listening/talking on the same port.

  myPort = new Serial(this, portName, 9600); //set up your port to listen to the serial port

  table.addColumn("id"); //This column stores a unique identifier for each record. We will just count up from 0 - so your first reading will be ID 0, your second will be ID 1, etc. 
  //  
  //  //the following adds columns for time. You can also add milliseconds. See the Time/Date functions for Processing: https://www.processing.org/reference/ 
  //  table.addColumn("year");
  //  table.addColumn("month");
  //  table.addColumn("day");
  //  table.addColumn("hour");
  //  table.addColumn("minute");
  //  table.addColumn("second");
  //  
  //  //the following are dummy columns for each data value. Add as many columns as you have data values. Customize the names as needed. Make sure they are in the same order as the order that Arduino is sending them!
  table.addColumn("load1");
  table.addColumn("load2");
  table.addColumn("load3");
  table.addColumn("load4");

  size(600, 400);
  background(0);
  //print(font.list());
}

void serialEvent(Serial myPort) {
}

void draw()
{
  
  // Get value from Arduino. We will parse the data by each newline separator. 
  val = myPort.readStringUntil('\n');
  // for debugging purposes
  //val = debugLoad + ", " + debugLoad + ", " + debugLoad + ", " + debugLoad + "\n";
  
  //Check if we have a reading. If so, record it.
  if (val!= null) { 
    val = trim(val); //gets rid of any whitespace or Unicode nonbreakable space
    //println(val); //Optional, useful for debugging. If you see this, you know data is being sent. Delete if  you like. 
    float loadVals[] = float(split(val, ',')); //parses the packet from Arduino and places the valeus into the sensorVals array. I am assuming floats. Change the data type to match the datatype coming from Arduino. 

    if (loadVals.length == 4) {
      background(0);
      // Calculate the total of all four sensors
      totalLoad = loadVals[0]+loadVals[1]+loadVals[2]+loadVals[3];
      if (totalLoad > loadGoal1 && totalLoad < loadGoal2) {
        goal1 = true;
      } else if (totalLoad > loadGoal2) {
        goal1 = true;
        goal2 = true;
      }
      fill(255, 255, 255);
      text("Load 1 = " + loadVals[0], 10, 40);
      text("Load 2 = " + loadVals[1], 10, 80);
      text("Load 3 = " + loadVals[2], 10, 120);
      text("Load 4 = " + loadVals[3], 10, 160);
      text("Total = " + totalLoad, 10, 200);
      if (goal2 == true) {
        fill(0, 255, 0);
        text("98 N Goal Achieved!", 10, 260);
      } else if (goal1 == true) {
        println(". Goal 1 Acheived!");
        fill(255, 255, 0);
        text("49 N Goal Achieved!", 10, 260);
      }

      if (start == true && pause == false) {
      print(loadVals[0]);
      print(", ");
      print(loadVals[1]);
      print(", ");
      print(loadVals[2]);
      print(", ");
      println(loadVals[3]);
      print("Total = ");
      println(totalLoad);
      
        
        
        //debugLoad = debugLoad + .1;

        TableRow newRow = table.addRow(); //add a row for this new reading
        newRow.setInt("id", table.lastRowIndex());//record a unique identifier (the row's index)

        //record time stamp
        //newRow.setInt("year", year());
        //newRow.setInt("month", month());
        //newRow.setInt("day", day());
        //newRow.setInt("hour", hour());
        //newRow.setInt("minute", minute());
        //newRow.setInt("second", second());

        //record sensor information. Customize the names so they match your sensor column names. 
        newRow.setFloat("load1", loadVals[0]);
        newRow.setFloat("load2", loadVals[1]);
        newRow.setFloat("load3", loadVals[2]);
        newRow.setFloat("load4", loadVals[3]);

        text("press x to stop, p to pause", 10, 280);
      } else if (pause == true) {
        text("press p to continue", 10, 280);
      } else {
        text("press s to start", 10, 300);
        goal1 = false;
        goal2 = false;
      }
    }
  } else {
    background(0);
    text("Looking for data....", 10, 360);
  }
}

void keyPressed() {
  if ((key == 'S') || (key == 's') && start == false) {
    start = true;
    pause = false;
    ++fileCounter;
    table.clearRows();
    // Write a to the arduino serial port to start
    myPort.write('s');
    println("Sent start message to Arduino");
  }
  if ((key == 'B') || (key == 'b') && start == false) {
    // Write to the arduino serial port
    myPort.write('b');
    println("Sent backward message to Arduino");
  }
  if ((key == 'Z') || (key == 'z') && start == false) {
    // Write to the arduino serial port
    myPort.write('z');
    println("Sent zero message to Arduino");
  }
  if ((key == 'P') || (key == 'p')) {
    // Send a pause message to the Arduino
    pause = !pause;
    myPort.write('p');
    println("Sent pause message to Arduino");
  }
  if ((key == 'X') || (key == 'x')) {
    myPort.write('x');
    println("Sent stop message to Arduino");
    //for debugging
    debugLoad = 0;
    if (start == true) {
      start = false;
      goal1 = false;
      goal2 = false;
      fileName = str(year()) + str(month()) + str(day()) + str(minute()) + "-" + fileCounter + ".csv"; //this filename is of the form year+month+day+readingCounter
      saveTable(table, fileName); //Woo! save it to your computer. It is ready for all your spreadsheet dreams.
    }
  }
}