/*

Code for running multi level IR illumination system
  Input: binary TTL on D5 and D4
  Output: analog signal from DAC to LED analog input as function of D5/D4 combination

  Version one:
    DAC outputs two levels of voltage, based on presence of input on D4 (INP1)
    This allows wiring main FScope arduino and IR LED

*/

#include <Wire.h>
#include <Adafruit_MCP4725.h>

Adafruit_MCP4725 dac;
int INP1 = 4; // D4 input
int INP2 = 5; // D5 input

int dac_very_high = 670; // brightness level of IR LED at D5 HIGH input
int dac_high = 510; // brightness level of IR LED at HIGH input, ~66% of dynamic range
int dac_low  = 350; // brightness level of IR LED at LOW input, ~50% of dynamic range

void setup() {

  Serial.begin(9600);
  Serial.println("["+String(millis()/1000) + "] Booting up...");

  dac.begin(0x62);
  pinMode (INP1, INPUT);
  pinMode (INP2, INPUT);

  dac.setVoltage(dac_very_high, false);
  delay(2000);
  dac.setVoltage(dac_high, false);
  delay(2000);
  dac.setVoltage(dac_low, false);
  delay(2000);
  dac.setVoltage(0, false);
  delay(2000);

  Serial.println("["+String(millis()/1000) + "] Starting loop: D4 triggers DAC to go from " + String(dac_low) +" to "+String(dac_high) + " to " + String(dac_very_high));
   // If by accident we starting this script rather than behavioral script
  Serial.println("THIS IS MultiLEVEL Arduino, NOT THE RIGHT ONE FOR LEARNING EXPERIMENTS");
}


void loop() {

  if(digitalRead(INP1)==HIGH){
    if(digitalRead(INP2)==HIGH){
      dac.setVoltage(dac_very_high, false);
      Serial.println("Set VERY HIGH");
    }else{
      dac.setVoltage(dac_high, false);
      Serial.println("Set HIGH");
    }
  }else{
    dac.setVoltage(dac_low, false);
      Serial.println("Set LOW");
  }

}
