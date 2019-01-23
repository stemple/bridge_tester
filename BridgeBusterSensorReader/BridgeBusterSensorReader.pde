/*
 This software reads from an Arduino serially, which is reading out four
 load sensors for testing model bridges.
 
 This code is modified from a tutorial by Elaine Laguerta (http://url/of/online/tutorial.cc)
 
 */

import processing.serial.*;
import org.gicentre.utils.stat.*;    // For chart classes.

Serial myPort; //creates a software serial port on which you will listen to Arduino
XYChart[] charts;
FloatList load_data1 = new FloatList();
FloatList load_data2 = new FloatList();
FloatList load_data3 = new FloatList();
FloatList load_data4 = new FloatList();
FloatList time_data = new FloatList();
Table table = new Table(); //table where we will read in and store values. You can name it something more creative!

int numReadings = 10; //keeps track of how many readings you'd like to take before writing the file. 
int readingCounter = 0; //counts each reading to compare to numReadings. 

float loadGoal1 = 49;
float loadGoal2 = 98;

float totalLoad;

boolean goal1 = false;
boolean goal2 = false;

boolean goal1Passed = false;
boolean goal2Passed = false;

String fileName;
String val;
boolean started = false;
boolean pause = false;
int fileCounter = 0;

// for debugging
float debugLoad = 0;
int counter = 0;

void setup()
{
  size(800, 600);
  textFont(createFont("Courier", 10), 10);

  // Set up the charts
  // Both x and y data set here.  
  charts = new XYChart[4];

  for (int i = 0; i < 4; i++) {
    charts[i] = new XYChart(this);
    // Axis formatting and labels.
    charts[i].showXAxis(true); 
    charts[i].showYAxis(true); 
    charts[i].setMinY(0);
    charts[i].setMaxY(70);

    // Symbol colours
    charts[i].setPointColour(color(180, 50, 50, 100));
    charts[i].setPointSize(5);
    charts[i].setLineWidth(2);
  }


  String ports[] = Serial.list();
  String portName = Serial.list()[3];

  for (int i = 0; i < ports.length; i++) {
    println("Port " + i + " = " + ports[i]);
  }

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
  if (val != null) {
    background(255);
    val = trim(val); //gets rid of any whitespace or Unicode nonbreakable space
    //println(val); //Optional, useful for debugging. If you see this, you know data is being sent. Delete if  you like. 
    float loadVals[] = float(split(val, ',')); //parses the packet from Arduino and places the valeus into the sensorVals array. I am assuming floats. Change the data type to match the datatype coming from Arduino. 

    if (loadVals.length == 4) {
      // Calculate the total of all four sensors
      totalLoad = loadVals[0]+loadVals[1]+loadVals[2]+loadVals[3];
      if (totalLoad > loadGoal1 && totalLoad < loadGoal2) {
        goal1 = true;
      } else if (totalLoad > loadGoal2) {
        goal1 = true;
        goal2 = true;
      }

      int chartwidth = (width/2)-20;
      int chartheight = (height/2)-100;
      if (goal1 != true && goal2 != true) {
        fill(200);
        rect(5, height-60, width-10, 50, 5);
      }
      if (goal1 == true) {
        fill(255, 255, 0);
        rect(5, height-60, width-10, 50, 5);
      }
      if (goal2 == true) {
        fill(0, 255, 0);
        rect(5, height-60, width-10, 50, 5);
      }
      fill(120);
      textSize(15);
      text("Load 1 = " + loadVals[0], 50, chartheight + 75);
      text("Load 2 = " + loadVals[1], chartwidth+ 50, chartheight + 75);
      text("Load 3 = " + loadVals[2], 50, chartheight*2 + 125);
      text("Load 4 = " + loadVals[3], chartwidth+50, chartheight*2 + 125);
      textSize(20);
      fill(0);
      text("Total Load = " + totalLoad + " Newtons", width/2 - 200, height-30);
      if (goal2 == true && goal2Passed == false) {
        text("98 N Goal Achieved!", 10, height - 20);
        //pause();
        goal2Passed = true;
      } else if (goal1 == true && goal1Passed == false) {
        println(". Goal 1 Acheived!");
        text("49 N Goal Achieved!", 10, height - 20);
        //pause();
        goal1Passed = true;
      }
      textSize(9);

      charts[0].draw(10, 50, chartwidth, chartheight);
      charts[1].draw(chartwidth + 10, 50, chartwidth, chartheight);
      charts[2].draw(10, chartheight+100, chartwidth, chartheight);
      charts[3].draw(chartwidth + 10, chartheight+100, chartwidth, chartheight);

      if (started == true && pause == false) {
        load_data1.append(loadVals[0]);
        load_data2.append(loadVals[1]);
        load_data3.append(loadVals[2]);
        load_data4.append(loadVals[3]);
        time_data.append(counter++);
        charts[0].setData(time_data.array(), load_data1.array());
        charts[1].setData(time_data.array(), load_data2.array());
        charts[2].setData(time_data.array(), load_data3.array());
        charts[3].setData(time_data.array(), load_data4.array());

        // Send data to serial
        print(loadVals[0]);
        print(", ");
        print(loadVals[1]);
        print(", ");
        print(loadVals[2]);
        print(", ");
        println(loadVals[3]);
        print("Total = ");
        println(totalLoad);

        debugLoad = debugLoad + random(-1, 5)*.01;

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
        textSize(20);
        text("press x to stop, p to pause", 20, 20);
      } else if (pause == true) {
        textSize(20);
        text("press p to continue", 20, 20);
      } else {
        textSize(20);
        text("press s to start", 20, 20);
        goal1 = false;
        goal2 = false;
      }
    }
  } else {
    fill(255);
    rect(20, 25, width-30, 20);
    fill(120);
    textSize(15);
    text("Looking for data....", 20, 40);
    //text("Press 'S' to begin data collection.", 20, 60);
  }
}

void keyPressed() {
  if ((key == 'S') || (key == 's') && started == false) { //<>//
    begin();
  }
  if ((key == 'B') || (key == 'b') && started == false) {
    // Write to the arduino serial port
    myPort.write('b');
    println("Sent backward message to Arduino");
  }
  if ((key == 'Z') || (key == 'z') && started == false) {
    // Write to the arduino serial port
    myPort.write('z');
    println("Sent zero message to Arduino");
  }
  if ((key == 'P') || (key == 'p')) {
    pause();
  }
  if ((key == 'X') || (key == 'x')) {
    stop();
  }
}

void pause() {
  // Send a pause message to the Arduino
  pause = !pause;
  myPort.write('p');
  println("pause = " + pause);
  println("Sent pause message to Arduino");
}

void begin() {
  started = true;
  pause = false;
  ++fileCounter;
  table.clearRows();
  // Write a to the arduino serial port to start
  myPort.write('s');
  println("Sent start message to Arduino");
}

void stop() {
  myPort.write('x');
  println("Sent stop message to Arduino");
  //for debugging
  debugLoad = 0;
  totalLoad = 0;
  counter = 0;
  load_data1.clear();
  load_data2.clear();
  load_data3.clear();
  load_data4.clear();
  time_data.clear();
  if (started == true) {
    started = false;
    goal1 = false;
    goal2 = false;
    fileName = str(year()) + str(month()) + str(day()) + str(minute()) + "-" + fileCounter + ".csv"; //this filename is of the form year+month+day+readingCounter
    saveTable(table, fileName); //Woo! save it to your computer. It is ready for all your spreadsheet dreams.
  }
}