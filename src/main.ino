/*
Controlling a car in an open loop system via Kinect controls.
 Victor Amaral, Sarah Azody, Kevin Rowland
 */
#include <SoftwareSerial.h>
#include <VirtualWire.h>h
//SoftwareSerial mySerial = SoftwareSerial(2, 3); //(rxPin, txPin)

int SON_pin = 8;
int left, right;
boolean test = false;

const int rx_pin = 2;
const int L_Speed = 5;        //enable pin right side
const int L_Direction = 4;    //logic pin left
const int R_Speed = 3 ;       //enable pin right side
const int R_Direction = 6 ;   //logic pin right

void setup() {
  //pinMode(rx_pin, INPUT);
  pinMode(L_Speed, OUTPUT);
  pinMode(R_Speed, OUTPUT);
  Serial.begin(2400);
  
  vw_setup(2400);        //baud for wireless rx
  vw_set_rx_pin(rx_pin);      //receive wireless data on pin 2
  vw_rx_start();         //start rx process
  
  digitalWrite(L_Direction, 1);
  digitalWrite(R_Direction, 1);  
  
}

void loop () {

  /*--------------READ FROM RCVR--------------*/
  
  byte buflen = VW_MAX_MESSAGE_LEN;
  byte buf[buflen]; //buffer to store the received data
  
  if (vw_have_message()) {                //if a message is transmitted
      vw_get_message(buf, &buflen);       //save the message to buffer;
        writeToMotor(buf[0], buf[1]);
        Serial.print(buf[0]);             //debug for demonstration purposes            
        Serial.print('*');
        Serial.println(buf[1]);
  }
}

 /*--------------WRITE TO MOTOR--------------*/
 
void writeToMotor(int xPos, int yPos) {
  if(xPos < 100) {                      //turn left
    left = yPos - (128 - xPos);
    right = yPos;
  } else if ( xPos > 156 ) {            //turn right
    left = yPos;
    right = yPos - (255 - xPos + 128);
  } else {                              //go straight!
    right = yPos;
    left = yPos;
  } 
 analogWrite(L_Speed, left);
 analogWrite(R_Speed, right);
 delay(100);
}
