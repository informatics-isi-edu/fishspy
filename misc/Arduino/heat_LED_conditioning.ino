/*

Condition fish to associate LED light with heat

LED control: TTL-level trigger digital signal on/off 5V
Heat control: analog modulation

Main section of the code is in the "loop(){}" section
Requires Adafruit MCP4725 library: https://github.com/adafruit/Adafruit_MCP4725
*/

#include <Wire.h>
#include <Adafruit_MCP4725.h>

Adafruit_MCP4725 dac;
#define laserVoltage 2400

#define ITI 2 // minutes between test/hab
#define pausing 0 // minutes between phases
#define CSLen 8 // seconds for conditioned stimulus (LED)
#define USLen 2 // seconds for unconditioned stimulus (heating laser)
#define waitLen 28 // minutes for wait period

int LED = 4; // standard pin for LEDs
int OUT2 = 5; // digital pin 2
int OUT3 = 6; // digital pin to drive 2nd IR level independently from LED

void setup() {
  Serial.begin(9600);
  display_Running_Sketch();


  dac.begin(0x62);
  pinMode (LED, OUTPUT);
  digitalWrite (LED, LOW);
  pinMode (OUT2, OUTPUT);
  digitalWrite (OUT2, LOW);
  pinMode (OUT3, OUTPUT);
  digitalWrite (OUT3, LOW);
  dac.setVoltage(0, false);

  Serial.println("["+String(millis()/1000) + "] Waiting 1 minute. Turn video recording ON now.");
  waitMinute(1);
}

void loop() {
  // Main protocol section
  // Habituation stage
  testing("Habituation", 20);

  // First training stage
  training(10);

  waitMinute(waitLen);
  // Second training stage
  training(10);

  waitMinute(waitLen);

  // Testing
  testing("Testing",5);

  // Retraining
  training(10);

  Serial.println("["+String(millis()/1000) + "] Behavior Protocol finished");
  while(1){}

}

void testing(String msg, int rep_num){
  // Only present light stimulation for CSLen+USLen seconds
  for(int rep=0;rep<rep_num;rep++){
    Serial.println("["+String(millis()/1000) + "] "+msg+" rep #" + String(rep) + "/" + String(rep_num));
    digitalWrite(LED, HIGH);
    digitalWrite (OUT3, HIGH);
    waitSecond(CSLen+USLen);
    digitalWrite(LED, LOW);
    digitalWrite (OUT3, LOW);
    waitMinute(ITI);

  }
}

void training(int rep_num){
  // Present light stimulation for CSLen and light+laser for USLen after that
  for(int rep=0;rep<rep_num;rep++){
    Serial.println("["+String(millis()/1000) + "] Training rep #" + String(rep) + "/" + String(rep_num));

    digitalWrite(LED, HIGH);
    digitalWrite (OUT3, HIGH);
    waitSecond(CSLen);

    digitalWrite(OUT2, HIGH);
    dac.setVoltage(laserVoltage, false);
    waitSecond(USLen);

    digitalWrite(LED, LOW);
    digitalWrite (OUT3, LOW);
    dac.setVoltage(0, false);
    digitalWrite(OUT2, LOW);
    waitMinute(ITI);

  }

}

void waitMinute(int mins){
  for(int i=0;i<mins;i++){
    Serial.println("["+String(millis()/1000) + "] waitMinute "+ String(i)+"/"+String(mins));
    waitSecond(60);
  }
}

void waitSecond(int secs){
  for(int j=0;j<secs;j++){
    delay(1000);
  }
}


void display_Running_Sketch (void){
  // Code to display path to the script we are running
  // Useful for debugging and making sure you run the correct script
  String the_path = __FILE__;
  int slash_loc = the_path.lastIndexOf('/');
  String the_cpp_name = the_path.substring(slash_loc+1);
  int dot_loc = the_cpp_name.lastIndexOf('.');
  String the_sketchname = the_cpp_name.substring(0, dot_loc);

  Serial.print("\nArduino is running Sketch: ");
  Serial.println(the_sketchname);
  Serial.print("Compiled on: ");
  Serial.print(__DATE__);
  Serial.print(" at ");
  Serial.print(__TIME__);
  Serial.print("\n");
}
