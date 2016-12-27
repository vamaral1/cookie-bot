/*
arduino_output

Demonstrates the control of digital pins of an Arduino board running the
StandardFirmata firmware.  Clicking the squares toggles the corresponding
digital pin of the Arduino.  

To use:
* Using the Arduino software, upload the StandardFirmata example (located
  in Examples > Firmata > StandardFirmata) to your Arduino board.
* Run this sketch and look at the list of serial ports printed in the
  message area below. Note the index of the port corresponding to your
  Arduino board (the numbering starts at 0).  (Unless your Arduino board
  happens to be at index 0 in the list, the sketch probably won't work.
  Stop it and proceed with the instructions.)
* Modify the "arduino = new Arduino(...)" line below, changing the number
  in Arduino.list()[0] to the number corresponding to the serial port of
  your Arduino board.  Alternatively, you can replace Arduino.list()[0]
  with the name of the serial port, in double quotes, e.g. "COM5" on Windows
  or "/dev/tty.usbmodem621" on Mac.
* Run this sketch and click the squares to toggle the corresponding pin
  HIGH (5 volts) and LOW (0 volts).  (The leftmost square corresponds to pin
  13, as if the Arduino board were held with the logo upright.)
  
For more information, see: http://playground.arduino.cc/Interfacing/Processing
*/
import cc.arduino.*;

Serial arduino;

/*
This code imports everything from SimpleOpenNI library and declares 
a variable of the type SimpleOpenNI named kinect.
*/
import SimpleOpenNI.*; 
import processing.serial.*;

/*-------------------------------- KINECT --------------------------------*/
SimpleOpenNI  kinect; 
PImage img;
//...add more declarations here...
 
/* 
Sets the size of application window and creates a new SimpleOpenNI kinect, 
that can be used to communicate with the Kinect device.
*/
void setup(){
  
/*-------------------------------- KINECT --------------------------------*/

  //set size of the application window
  size(640, 480); 
  //initialize kinect variable
  kinect = new SimpleOpenNI(this);
  //asks OpenNI to initialize and start receiving depth sensor's data
  kinect.enableDepth(); 
  //asks OpenNI to initialize and start receiving User data
  kinect.enableUser(); 
  //enable mirroring - flips the sensor's data horizontally
  kinect.setMirror(true); 
  //... add more variable initialization code here...
  img=createImage(640,480,RGB);
  img.loadPixels();
  
/*-------------------------------- ARDUINO -------------------------------*/
  // Prints out the available serial ports.
  println(Arduino.list());
  
  // Modify this line, by changing the "0" to the index of the serial
  // port corresponding to your Arduino board (as it appears in the list
  // printed by the line above).
  arduino = new Serial(this, "/dev/tty.usbmodem1421", 9600);

}

float xPosition, yPosition;
float test;

/*
Clears the screen, gets new data from Kinect and draw a depthmap to the 
screen.
*/
void draw(){
  //clears the screen with the black color, this is usually a good idea 
  //to avoid color artefacts from previous draw iterations
  background(255);
 
  //asks kinect to send new data
  kinect.update();
 
  //retrieves depth image
  PImage depthImage=kinect.depthImage();
  depthImage.loadPixels();
 
  //get user pixels - array of the same size as depthImage.pixels, that gives information about the users in the depth image:
  // if upix[i]=0, there is no user at that pixel position
  // if upix[i] > 0, upix[i] indicates which userid is at that position
  int[] upix=kinect.userMap();
 
  //colorize users
  for(int i=0; i < upix.length; i++){
    if(upix[i] > 0){
      //there is a user on that position
      //NOTE: if you need to distinguish between users, check the value of the upix[i]
      img.pixels[i]=color(0,0,255);
    }else{
      //add depth data to the image
     img.pixels[i]=depthImage.pixels[i];
    }
  }
  img.updatePixels();
 
  //draws the depth map data as an image to the screen 
  //at position 0(left),0(top) corner
  image(img,0,0);
 
  //draw significant points of users
 
  //get array of IDs of all users present 
  int[] users=kinect.getUsers();
 
  ellipseMode(CENTER);
 
  //iterate through users
  for(int i=0; i < users.length; i++){
    int uid=users[i];
    
    //draw center of mass of the user (simple mean across position of all user pixels that corresponds to the given user)
    PVector realCoM=new PVector();
    
    //get the CoM in realworld (3D) coordinates
    kinect.getCoM(uid,realCoM);
    PVector projCoM=new PVector();
    
    //convert realworld coordinates to projective (those that we can use to draw to our canvas)
    kinect.convertRealWorldToProjective(realCoM, projCoM);
    fill(255,0,0);
    ellipse(projCoM.x,projCoM.y,10,10);
    
    //check if user has a skeleton
    if(kinect.isTrackingSkeleton(uid)){
      //draw head
      PVector realHead=new PVector();
      
      //get realworld coordinates of the given joint of the user (in this case Head -> SimpleOpenNI.SKEL_HEAD)
              kinect.getJointPositionSkeleton(uid,SimpleOpenNI.SKEL_HEAD,realHead);
      PVector projHead=new PVector();
      kinect.convertRealWorldToProjective(realHead, projHead);
      fill(0,255,0);
      ellipse(projHead.x,projHead.y,10,10);
 
      //draw left hand
      PVector realLHand=new PVector();
      kinect.getJointPositionSkeleton(uid,SimpleOpenNI.SKEL_LEFT_HAND,realLHand);
      PVector projLHand=new PVector();
      kinect.convertRealWorldToProjective(realLHand, projLHand);
      fill(255,255,0);
      ellipse(projLHand.x,projLHand.y,10,10);
      
      /*Steering control*/
      float xRelative = (projCoM.x - projLHand.x - 100);
      float yRelative = (projCoM.y - projLHand.y);
      
      byte xCorrected, yCorrected;
      
      if(xRelative < 0)            { xCorrected = byte(0); }
      else if(xRelative > 255)     { xCorrected = byte(255); }
      else                         { xCorrected = byte(xRelative); }
      
      if(yRelative < -128)         { yCorrected = byte(0); }
      else if(yRelative > 127)     { yCorrected = byte(255); }
      else                         { yCorrected = byte(yRelative + 128); }
      
      arduino.write('S');
      arduino.write(int(xCorrected));
      arduino.write(int(yCorrected));
      //println("x: " + int(xRelative) + ", x corrected: " + int(xCorrected));
      //println("y: " + int(yRelative) + ", y corrected: " + int(yCorrected));
      delay(300);
    }
  }

}
 
//is called everytime a new user appears
void onNewUser(SimpleOpenNI curkinect, int userId)
{
  println("onNewUser - userId: " + userId);
  //asks OpenNI to start tracking a skeleton data for this user 
  //NOTE: you cannot request more than 2 skeletons at the same time due to the perfomance limitation
  //      so some user logic is necessary (e.g. only the closest user will have a skeleton)
  curkinect.startTrackingSkeleton(userId);
}
 
//is called everytime a user disappears
void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
 
}

String serialIndexFor(String name) throws Exception {
  for ( int i = 0; i < Serial.list().length; i ++ ) {
    String[] part = match(Serial.list()[i], name);
    if (part != null) {
      println(Serial.list()[i]);
      return Serial.list()[i];
    }
  }
  throw new Exception("Serial port named '" + name + "' could not be found");
}
