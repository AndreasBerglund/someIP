

//OSC 
import oscP5.*;
import netP5.*;
OscP5 oscP5;

/* a NetAddress contains the ip address and port number of a remote location in the network. */
NetAddress myBroadcastLocation; 
 String[] ip;
 String _ip;
 long previousMillis = 0; 
 long interval = 20000;  
 boolean reloadServer = false;
//knap
Button b1;
Button b2;
Button b3;
Button b4;
Button b5;
Button b6;
String s = "Choose side!";

//webcam
import processing.video.*;
Capture webcam;
import processing.net.*;
PImage prevFrame;

//!!!!!set addresse på client /nummer!!!!!

int number = 0;
String locName = "N/A";

//LYD

import ddf.minim.*;
import processing.sound.*;

Minim minim;
AudioInput input;

void setup() {
  size(800, 400);

  //WEBCAM OG PREVFRAME
  webcam = new Capture(this, 640, 480);  
  String[] devices = Capture.list();
  //String[] ip;
  prevFrame = createImage(webcam.width, webcam.height, RGB);
  webcam.start();

  //LYD
  minim = new Minim(this);
  input = minim.getLineIn(Minim.STEREO, 512);

  //knap
textSize(48);
text(s, 100, 100); 


int btnWidth = 125;
int xpos = 25;
int ypos =height/2;
    b1 = new Button(xpos, ypos, btnWidth, 100, "ID");
    b2 = new Button(xpos+btnWidth*1, ypos, btnWidth, 100, "GD");
    b3 = new Button(xpos+btnWidth*2, ypos, btnWidth, 100, "FK");
    b4 = new Button(xpos+btnWidth*3, ypos, btnWidth, 100, "KK");
    b5 = new Button(xpos+btnWidth*4, ypos, btnWidth, 100, "TVM");
    b6 = new Button(xpos+btnWidth*5, ypos, btnWidth, 100, "MPL");


  oscP5 = new OscP5(this, 32000);

  //!!!!!!!!!modtager server IP;!!!!!!!!!!!

 String[]  ip =  loadStrings("http://www.stigmollerhansen.dk/ip.html");
//  println(ip[0])
_ip = ip[0];
  
  myBroadcastLocation = new NetAddress(_ip, 32000);
}


void draw() {
  println(_ip);
  println(reloadServer);
  long currentMillis = millis();


if(currentMillis - previousMillis >= interval) {
  
    reloadServer = true;
    
 
    previousMillis = currentMillis;   
}



if(reloadServer) {
  
  String ip[] =  loadStrings("https://raw.githubusercontent.com/AndreasBerglund/someIP/master/ip.txt");
  myBroadcastLocation = new NetAddress(_ip, 32000);
  reloadServer = false;
  _ip = ip[0];
   
   println(myBroadcastLocation);

}


  b1.update();
  b2.update();
  b3.update();
  b4.update();
  b5.update();
  b6.update();


 if(b1.clicked)background(#00ffca); if(b2.clicked)background(#00ffca);
  if(b3.clicked)background(#00ffca); if(b4.clicked)background(#00ffca);
   if(b5.clicked)background(#00ffca); if(b6.clicked)background(#00ffca);
   
   





// background(0);



//TEGN WEBCAM
if (webcam.available() == true) {
  prevFrame.copy(webcam, 0, 0, webcam.width, webcam.height, 0, 0, webcam.width, webcam.height);
  prevFrame.updatePixels();
  webcam.read(); 
  //image(webcam,0,0);
}

//UDREGN MOTION VARIABEL
//load pixels detect motion

loadPixels();
webcam.loadPixels();
prevFrame.loadPixels();

//total motion start with 0

float totMotion = 0;

//sum brightness of each pixels

for (int i = 0; i <webcam.pixels.length; i++) {

  color current = webcam.pixels[i];
  color previous = prevFrame.pixels[i];

  //rgb og compare colors

  float r1 = red(current);
  float r2 = red(previous);
  float g1 = green(current);
  float g2 = green(previous);
  float b1 = blue(current);
  float b2 = blue(previous);

  float difference = dist(r1, g1, b1, r2, g2, b2);
  if (difference > 20 ) {
    totMotion += 1;
  }
}

//UDREGN LYDVARIABEL //ANALYSER LYD
float totSound = input.mix.level()*512 ;

//tegn værdier lokalt

rect(0, 0, 30, totSound);
rect(60, 0, 30, totMotion/10000);

//remmap værdier til float mellem 0 og 1;
float totFinalSound = map(totSound, 0, 512, 0, 1);
float totFinalMotion = map(totMotion, 0, webcam.pixels.length, 0, 1);

//println(totFinalMotion);
//println("lyd"+totFinalSound);
//println(locName);
// SKRIV OSC OG SEND TIL SERVER

OscMessage myOscMessage = new OscMessage("/motion");

myOscMessage.add(totFinalMotion);
myOscMessage.add(totFinalSound);
myOscMessage.add(locName);

oscP5.send(myOscMessage, myBroadcastLocation);

}

//class btn
class Button{
  int xpos, ypos, wid, hei;
  String label;
  boolean over = false;
  boolean down = false; 
  boolean clicked = false;
  Button(
  int tx, int ty,
  int tw, int th,
  String tlabel
  ){
    xpos = tx;
    ypos = ty;
    wid = tw;
    hei = th;
    label = tlabel;
  }
  
  void update(){
    //it is important that this comes first
    if(down&&over&&!mousePressed){
      clicked=true;
      locName = label;
    
    }else{
      clicked=false;
    }
    
    //UP OVER AND DOWN STATE CONTROLS
    if(mouseX>xpos && mouseY>ypos && mouseX<xpos+wid && mouseY<ypos+hei){
      over=true;
      if(mousePressed){
        down=true;
      }else{
        down=false;
      }
    }else{
      over=false;
    }
    smooth();
    
    //box color controls
    if(!over){
      
      fill(255);
    }else{
      if(!down){
        fill(100);
      }else{
        fill(0);
      }
    }
    stroke(0);
    rect(xpos, ypos, wid, hei, 10);//draws the rectangle, the last param is the round corners
    
    //Text Color Controls
    if(down){
      fill(255);
    }else{    
      fill(0);
    }
    textSize(20); 
    text(label, xpos+wid/2-(textWidth(label)/2), ypos+hei/2+(textAscent()/2)); 
    //all of this just centers the text in the box
  } 
}
    