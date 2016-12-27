## Cookie Bot

Project by Victor Amaral, Kevin Rowland, Sarah Azody

<img src="/img/bot.jpg" style="height: 50;width: 50"/>

A mobile robot controlled by an Arduino Uno and hand gestures using the Microsoft Kinect inspired by the [Cake Bot](https://www.codeproject.com/articles/672336/cakerobot-a-csharp-arduino-kinect-robot-that-follo).

Uses the OpenNI (Open Natural Interaction) library called [SimpleOpenNI](https://code.google.com/archive/p/simple-openni/) for [Processing](http://playground.arduino.cc/Interfacing/Processing)

### Introduction

Using the Kinect, we thought it would be exciting if we could create a gesture controlled car. If we move our hand to the left, the direction of the car will change to the left. If we move our hand to the right, the car will begin to move to the right. If we move our hand up, it will increase it’s speed while if our hand moves down it will decrease its speed.

The Kinect reads the position of one hand into (x,y) values. We then map those values to the Arduino controls. We use one Arduino connected to our laptop to perform this mapping which then transmits data to another Arduino on the car which controls its motors.

### Sensor and Actuator Details

**Kinect**

The Kinect is designed to interpret specific gestures, making completely hands-free control of electronic devices by using an infrared projector and camera with a special microchip to track movement of objects and individuals in three dimensions. The 3D scanner system called Light Coding employs a variant of image-based 3D reconstruction. The Kinect sensor is a horizontal bar connected to a small base. It features an RGB camera and depth sensor which we use to control the direction of our car. The depth sensor consists of an infrared laser projected combined with a monochrome CMOs sensor which captures video data in 3D under ambient light. The sensor has a 1.2 - 3.5 m distance when used. It connects via USB for communication and alternate AC adapter for power. We use the gesture control from the Kinect to communicate x- and y- positions to our Arduino with a transmitter so it can send the data to an Arduino on the car. 

**RF Transmitter/Receiver**

For wireless communication, we use an RF Transmitter/Receiver pair. 

The RF Transmitter TWS-BS-3 operates at 3 V and transmits data using a 434MHz frequency. This transmitter is connected to an Arduino that is plugged into the computer in order to directly receive data from the Kinect to prepare to transmit. The pins are numbered 1-4 and are connected to ground, a digital pin on the Arduino configured as output, 3.3 V, and a wire antenna respectively. We use the Arduino VirtualWire library to actually transmit the data. The data is transmitted at 2400 bits per second.

![Alt text](https://github.com/vamaral1/cookie-bot/blob/master/img/transmitter.png) 

The RF Receiver RWS-371-6 operates at 5V and uses the 434 MHz frequency in order to communicate with the transmitter. We placed the receiver on the Arduino that controls the car. The job of the receiver is to gather the transmitted data and send it to the Arduino so it can write data to the motors. The pins are numbered 1-8 and are connected to: ground, a digital pin on the Arduino in output mode, nothing, 5.5 V, 5.5 V, ground, ground, and a wire antenna. Pin 3 is not connected to anything as we don’t need to use the Linear Out functionality from the receiver. 

![Alt text](https://github.com/vamaral1/cookie-bot/blob/master/img/receiver.png) 

**Magician Chassis**

The chassis is a ROB-12866 ROHS robot platform. It features two gearmotors with 65mm wheels and a rear caster. The chassis plates are cut from acrylic with a variety of mounting holes which we use to place our Arduino and sensors. We bolted the two pre-cut platforms together, attached the motors and caster, and placed our Arduino and extended breadboard atop. We use a 9V battery to power the Arduino and Arduino output power to drive the motors.

### Mapping Kinect input to Arduino

The Kinect data acquisition consisted of using code from OpenNI to track a user’s skeletal outline. Positions of various features of the skeleton can be grabbed from the library using the `getJointPositionSkeleton()` method. From this joint position object, various more specific features can be tracked. We used the Center of Mass (CoM) and the Left Hand of the user to control our robot. Specifically, we subtracted the LHand x- and y- components from the CoM x- and y- components to get a “distance away from CoM” value. 

As seen in the drawing on the left, the left hand position in the middle of our range sits at 178 units away from CoM in the x-direction and 0 units away from CoM in the y-direction. The top left corner would be 305 units away in the x-direction and 128 units away in the y-direction. Now that our range of motion was established, we had to convert those numbers to 8-bit values to be sent over the RF link as bytes. To do this, we subtracted 50 from the x value and added 127 to the y value. This resulted in the drawing on the right, which shows our full range of motion as a pair 8-bit values representing a point in 2-dimensional space.

![Alt text](https://github.com/vamaral1/cookie-bot/blob/master/img/mapping.jpg)
