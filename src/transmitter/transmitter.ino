#include <VirtualWire.h>

//byte* xPosition, yPosition;
byte myByte;
int val, xVal, yVal, xValPrev, yValPrev;
char* stuff;

int bytesAvailable;

void setup() {
  vw_set_ptt_inverted(true);     // Required for RF Link module
  vw_setup(2400);                // Bits per sec
  pinMode(12, OUTPUT);
  vw_set_tx_pin(12);             // pin 12 the transmit data out into the TX Link module.                     
  Serial.begin(9600);
}

void loop(){
  
  // check if data has been sent from the computer:
  if ((bytesAvailable = Serial.available()) > 2) { // If data is available to read,
    //Serial.println("there is data");
    val = Serial.read();
    //delay(3000);

    if(val == 'S'){
      // read the most recent byte (which will be from 0 to 255):
      xVal = Serial.read();
      yVal = Serial.read();
    }
    
    for(int i = 0; i < bytesAvailable - 3; i++) {
      Serial.read(); //trash the rest 
    }

  }
    Serial.print("x: ");
    Serial.print(int(xVal));
    Serial.print("y: ");
    Serial.println(int(yVal));
    //send byte array
    byte stuff[] = {xVal, yVal};
    if(xValPrev == xVal && yValPrev == yVal) {
      //do nothing
    } else {
      //byte stuff[] = {byte(200), byte(200)};
      //for(int i = 0; i < 10; i++) {
      vw_send(stuff, 2);    // Transmits data
      vw_wait_tx();      // Wait for message to finish
      delay(200);
    }
    
    xValPrev = xVal;
    yValPrev = yVal;
  
} 
