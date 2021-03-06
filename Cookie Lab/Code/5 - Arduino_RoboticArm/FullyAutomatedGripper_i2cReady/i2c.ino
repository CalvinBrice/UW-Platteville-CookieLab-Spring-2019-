//----------------------------------------
// i2c handler
//
//  Notes:
//    Not fully integrated yet 
//----------------------------------------

// function that executes whenever data is received from master
// this function is registered as an event, see setup()
void receiveEvent(int howMany) {

  //Nick add receiving code here
  while (!Wire.available());
  mainInControl = Wire.read(); // Sets mainInControl to false giving the ARM master control

  //Call runAutomation();
}

void runAutomation() {
  Serial.println("Begin automated procedure");
  //  automaticInstructions();

  Wire.begin(MASTER); // Gives the main arduino master control (This will go at the end of the runAutomation() function)
  Wire.write(true); // Sets MASTER's 'mainInControl' variable to true
  Wire.endTransmission();
  mainInControl = true;
}
