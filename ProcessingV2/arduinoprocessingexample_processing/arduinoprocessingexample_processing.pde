// Arduino/Procesing coupling example. 
//
// This example demonstrates transmitting values through the
// serial port from Arduino to Processing, using comma-delimited
// values (CSV). 
//
// This example displays the random values recieved from the Arduino.  


import processing.serial.*;
import processing.sound.*;

// Serial port vairables. 
Serial myPort;  // Create object from Serial class
SoundFile  sound;

float   ObjectDistance;
int     measuredAngle;
int     measuredDistance;
PFont   fontA;                  //Font (for drawing text)
int     screenshot_number = 0;  // Screenshot index (for taking screenshots).
float   translateWidth; 
float   translateHeight;


/* 
* Called whenever there is a new serial event. Parses the string, splitting 
* it by angle and distance and storing it into global variables, iAngle and
* iDistance.
*/
void serialEvent(Serial port) {
  // Data from the Serial port is read in serialEvent() using the 
  // readStringUntil() function with * as the end character.
  String input = port.readStringUntil(char(10)); 
  if (input != null) {
    // Helpful debug message: Uncomment to print message received   
    println( "Receiving:" + input);
    input = input.trim();    
    int split_point = input.indexOf(',');
    if (split_point <= 0) return;        // If data does not contain a comma, then disregard it. 
                                         // For example, when it says "initializing"
      // Parse data
      // The data is split into an array of Strings with a comma or 
      // asterisk as a delimiter and converted into an array of integers.
      float[] vals = float(splitTokens(input, ","));
      int x = int(vals[0]) - 1;
      int y = int(vals[1]) - 1;

     measuredAngle = x;
     measuredDistance = y;
      
      // Helpful debug message: Display serial data after parsing. 
      println ("Parsed x:" + x + "  y:" + y);
  }
}

// This function runs a single time after the program beings. 
void setup() {
  size(1280, 720); 
  // Initialize Serial Port
  println ("Available Serial Ports:");
  println (Serial.list());                     // Display a list of ports for the user.  
  String portName = Serial.list()[1];          // Change the index (e.g. 1) to the index of the serial port that the 
                                               // Arduino is connected to.
  print ("Using port: ");                      // Display the port that we are using. 
  println(portName); 
  println("This can be changed in the setup() function.");
  myPort = new Serial(this, portName, 9600);   // Open the serial port. (note, the baud rate (e.g. 9600) must match
                                               // the baud rate that the Arduino is transmitting at). 
    
  // Initialize font
  fontA = createFont("Arial-black", 20);
  textFont(fontA, 12);

  // Initialize sounds
   sound = new SoundFile(this, "beep.mp3");
   translateWidth = width / 2;
   translateHeight = height - height * 0.074;
}



void draw() {
  // fill(255, 255, 255); // blue color
  // noStroke();
  fill(0, 4);
  rect(0, 0, width, height - height * 0.065);
  fill(12, 33, 138); 

  background(255,255,255);
  drawRadar();
  drawLine();
  drawRedLine(); // draw redline after drawing line to overlap red ontop of green
  drawText();

}

void drawRadar() {
  pushMatrix();
  translate(translateWidth, translateHeight);
  noFill();
  strokeWeight(2);
  
  stroke(12, 33, 138); // blue color for the radar
  drawArc(0.0625);
  drawArc(0.27);
  drawArc(0.479);
  drawArc(0.687);

  line(-translateWidth, 0, translateWidth, 0);
  drawLines(30);
  drawLines(60);
  drawLines(90);
  drawLines(120);
  drawLines(150);
  line((-translateWidth)*cos(radians(30)), 0,translateWidth, 0);
  popMatrix();
}

/* 
* Helper function to draw a semi circle which will be apart of the Radar
* the value will change the size of the arc. This will be called 4 times
* during draw to get the radar look.
*/
void drawArc(float val) {
  arc(0, 0, (width - width * val), (width - width * val), PI, TWO_PI);
}

/*
* Helper function to draw lines at different angles which represent the 
* potential angles that the distance sensor will be looking at. This will
* be called 5 times and be spaced out in increments of 30 degrees
*/
void drawLines(int angle_in_radians) {
  line(0, 0, (-translateWidth)*cos(radians(angle_in_radians)), 
  (-translateWidth)*sin(radians(angle_in_radians)));
}

void drawRedLine() {
  pushMatrix();
  translate(translateWidth,translateHeight); // moves the starting coordinats to new location
  strokeWeight(9);
  stroke(255,10,10); // red color
  ObjectDistance = measuredDistance * ((height - height *0.1666) * 0.025); // distance of object from sensor in CM
  if(measuredDistance < 40) { // only draw if in distance
    line(ObjectDistance * cos(radians(measuredAngle)), 
    - ObjectDistance * sin(radians(measuredAngle)), 
    (width - width * 0.505) * cos(radians(measuredAngle)), 
    - (width - width * 0.505)*sin(radians(measuredAngle)));
  }
  popMatrix();
}

void drawLine() {
  pushMatrix();
  strokeWeight(9);
  stroke(22, 54, 217); // lighter blue color
  // moves to new position
  translate(translateWidth, translateHeight); 
  // draws the line at the position
  line(0, 0, (height - height * 0.12) * cos(radians(measuredAngle)), - (height - height * 0.12) * sin(radians(measuredAngle)));
  popMatrix();
}

void drawText() {
  pushMatrix();
  fill(255, 255, 255);
  noStroke();
  rect(0, height - height * 0.0648, width, height);
  fill(22, 54, 217); // blue
  textSize(25);
  
  drawTextDistance("10cm", 0.3854);
  drawTextDistance("20cm", 0.281);
  drawTextDistance("30cm", 0.177);
  drawTextDistance("40cm", 0.0729);
 
  textSize(40);
  text("Angle: " + measuredAngle +" °", width - width * 0.875, height - height * 0.0277 + 10);
  text("Distance: ", width - width * 0.48, height - height * 0.0277 + 10);
  if (measuredDistance < 40) {
    text(measuredDistance +" cm", width - width * 0.375 + 50, height - height * 0.0277 + 10);
  }
  if (measuredDistance < 15) { // play sound if object is close by
    sound.play();
    sound.amp(0.2);
  }
  // draw angle text on radar
  textSize(25);
  fill(22, 54, 217);
  drawAngleText();
  
  popMatrix();
}

void drawTextDistance(String text, float offset) {
  text(text, width - width * offset, height-height*0.0833);
}

void drawAngleText() {
  translate((width - width * 0.4994) + width / 2 * cos(radians(30)), 
  (height - height * 0.0907) - width / 2 * sin(radians(30)));
  rotate(-radians(-60));
  text("30°", 0, 0);
  resetMatrix();
  translate((width - width * 0.503) + width / 2 * cos(radians(60)), 
  (height - height * 0.0888) - width / 2 * sin(radians(60)));
  rotate(-radians(-30));
  text("60°", 0, 0);
  resetMatrix();
  translate((width - width * 0.507) + width / 2 * cos(radians(90)), 
  (height - height * 0.0833) - width / 2 * sin(radians(90)));
  rotate(radians(0));
  text("90°", 0, 0);
  resetMatrix();
  translate(width - width * 0.513 + width / 2 * cos(radians(120)), 
  (height - height * 0.07129) - width / 2 * sin(radians(120)));
  rotate(radians(-30));
  text("120°", 0, 0);
  resetMatrix();
  translate((width - width * 0.5104) + width / 2 * cos(radians(150)), 
  ( height - height * 0.0574) - width / 2 * sin(radians(150)));
  rotate(radians(-60));
  text("150°", 0, 0);
}


// This is another interrupt function that runs whenever a key is pressed.
// Here, as an example, if the space key (' ') is pressed, then the program will save a screenshot.
// If the 'a' key is pressed, then the program will clear the data history. 
void keyPressed() {
  // Press <space>: Save screenshot to file.
  if (key == ' ') {
   saveFrame("screenshot-" + screenshot_number + ".png"); 
   screenshot_number += 1;
  }
}
