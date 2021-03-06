//----------------------------------
//
// Load standardFirmata sketch onto arduino
//
//----------------------------------

import processing.serial.*;
import net.java.games.input.*;
import org.gamecontrolplus.*;
import org.gamecontrolplus.gui.*;
import cc.arduino.*;
import org.firmata.*;

ControlDevice cont;
ControlIO control;
Arduino arduino;
PFont f;

// pin assignments
int Finger_Pin = 9;
int Wrist_PIN = 10;
int Base_PIN = 11;

//float thumb;
float grip;    // Stores servo angle of gripper right finger
float wristRotationCW;     // Stores servo angle of gripper left finger
float wristRotationCCW;          // Stores servo angle of gripper wrist
float baseRotation;   // Stores input angle of gripper rotation
float basePos = 180;   // Stores current position of gripper rotation (0 ~ 180)
float basePosPrevious = basePos;   // Stores previous position of gripper rotation (0 ~ 180)
float verticalTravel; // Stores Nema 23 vertical height position
float verticalPos = 90;   // Stores position of gripper height

boolean wristPos = true;

float stickSensitivity = 0.075; // helps ignore imprecision in stick center

boolean debugTrue = true;

void setup() {
  size(600, 400); // Sets screen size
  f = createFont("Arial", 16, true); // Arial, 16 point, anti-aliasing on
  // Initialise the ControlIO
  control = ControlIO.getInstance(this);
  // Find a device that matches the configuration file
  cont = control.getMatchedDevice("xbsone"); // loads data file in sketch folder to map values from controller

  if (cont == null) {
    println("no controller detected"); // error message
    System.exit(-1);
  }

  println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[3], 57600); // enumerates connected USB ports

  arduino.pinMode(Finger_Pin, Arduino.SERVO);
  arduino.pinMode(Wrist_PIN, Arduino.SERVO);
  arduino.pinMode(Base_PIN, Arduino.SERVO);
}

public void getUserInput() {
  grip = map(cont.getSlider("grip").getValue(), -1, 0, 0, 180);
  if (grip <=0) { 
    grip = 0;
  } // ignores left trigger input

  baseRotation = cont.getSlider("baseRotation").getValue();
  basePos = stickMove(baseRotation, basePos, 0, 180); // changes output based on input
  //arduino.servoWrite(Base_PIN, (int)basePos);

  verticalTravel = cont.getSlider("verticalTravel").getValue();
  verticalPos = stickMove(verticalTravel, verticalPos, 0, 400); // changes output based on input
}

float stickMove(float input, float output, float lowerBound, float upperBound) {
  if (input < 0-stickSensitivity) { // checks if rotation needs to occur to the left
    if (output > lowerBound-input) { // allow input if actual position is not at extreme position
      output = output + input;
    }
  } 
  if (input > 0+stickSensitivity) {  // rotation needs to occur to the right
    if (output < upperBound-input) { // allow input if actual position is not at extreme position
      output = output + input;
    }
  }

  wristPos = cont.getButton("wristRotationCW").pressed();
  if (wristPos == true) {
    // Rotate right:
    arduino.servoWrite(Wrist_PIN, 107);
  } else {
    // Rotate left:
    arduino.servoWrite(Wrist_PIN, 6);
  }

  return output;
}

void draw() {
  getUserInput();
  background(grip, 100, 255);
  arduino.servoWrite(Finger_Pin, (int)grip);
  basePositioningFunction(basePos, basePosPrevious);
  debug();
  //delay(100);
}

int counter = 0;
void basePositioningFunction(float basePos, float basePosPrevious) {
  if  (basePos != basePosPrevious) {
    arduino.servoWrite(Base_PIN, (int)basePos);
    basePosPrevious = basePos;
    print(counter);
    counter = counter++;
    println(": Writing servo");
  }
}

void debug() { 
  if (debugTrue == true) {
    textFont(f, 40);  // STEP 3 Specify font to be used
    fill(0);          // STEP 4 Specify font color 

    // STEP 5 Display Text
    text("Gripper position:", 50, 50);
    text((int)grip, 400, 50);  

    text("Horizontal stick:", 50, 100);
    text(baseRotation, 400, 100);
    text("Horizontal position:", 50, 150);
    text((int)basePos, 400, 150);

    text("Vertical stick:", 50, 200);
    text(verticalTravel, 400, 200);
    text("Vertical position:", 50, 250);
    text((int)verticalPos, 400, 250);
  }
}
