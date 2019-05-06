void dispenseIngredients(int slave, byte bay, byte quantity) { // Variable is a distance/direction/step count/ depending on the slaveNumb and command
  mode = DISPENSE;
  Wire.beginTransmission(slave); // Transmit to device #(slaveNumb [numbered 1-4])
  Wire.write(bay);
  Wire.write(quantity);
  Wire.write(mode);
  Wire.endTransmission(); // Stop transmitting
  Serial.println("Bay: " + String(bay) + " | Quantity: " + String(quantity));
}
