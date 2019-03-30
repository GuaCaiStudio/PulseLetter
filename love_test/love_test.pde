import processing.serial.*;
import processing.pdf.*;

Serial sensorPort;
Serial printerPort;
PFont font;
PFont fontBold;
PFont fontLong;
PFont caption;
int xPos = 1;
float oldSensorHeight = 0;
float SensorHeight;
int scene = 1;

String receiverString = "";
String senderString = "";
ArrayList<Character> sender;
ArrayList<Character> receiver;
PImage img;

int startTime;



void setup(){
  size(800,480);
  font = createFont("Roboto-Regular.ttf", 18); 
  fontBold = createFont("Roboto-Bold.ttf",22);
  fontLong = createFont("Roboto-Regular.ttf",18);
  caption = createFont("Roboto-Light.ttf",14);
  sender = new ArrayList<Character>();
  receiver = new ArrayList<Character>();
  background(255);
  frameRate(60);
  sensorPort = new Serial(this,Serial.list()[3],115200);
  printerPort = new Serial(this, Serial.list()[0],19200);
}


void draw(){
  
   
      fill(0);
      textFont(font);
      receiverString = getNameString(receiver);
      senderString = getNameString(sender);
      
    if(scene == 1){
        xPos = 1;
        background(255);
        defaultScreen();
        textFont(fontBold);//Write in Bold
        text("Who would you like to write this letter to? ",width/2-200,height/2);
        textFont(caption);//Write caption
        text("(Type then press ENTER)",width/2-80,height/2 + 30);
     }
     
     if(scene == 2){
       
       background(255);
       defaultScreen();
        text("This is a special letter for you:",40,80);
        textFont(fontBold);//Write in Bold
        text("And what's your name? ",width/2-120,height/2);
        textFont(caption);//Write caption
        text("(Type then press ENTER)",width/2-80,height/2 +30);
        textFont(font);//Write in Regular
        if(senderString == " "){
          text("Sincerely,", width-80,height-60);
        }
     }
     
     
     if(scene == 9){
        background(255);
        defaultScreen();
        text("This is a special letter for you:",40,80);
        textFont(fontBold);//Write in Bold
        text("Now, place your finger on the green light sensor",width/2-238,height/2);
        textFont(caption);//Write caption
        text("(If you are ready, press SPACE and wait.)",width/2-130,height/2 +30);
        textFont(font);
     }
     
    if(scene == 3){
      sensorPort.write(0);
       //---------------------------------------------------------------------------------------------------drawing the diagram
      stroke(0);
      strokeWeight(2);
      float yPos = height- SensorHeight;
      float OldyPos = height- oldSensorHeight;
      line(xPos - 1, OldyPos, xPos, yPos);
      
      fill(map(SensorHeight,100,400,100,255),random(0,100),random(0,100),30);
      float r = SensorHeight/30;
      noStroke();
      ellipse(xPos, yPos+random(-8,8),r,r);
      
      oldSensorHeight = SensorHeight;
      
      if(xPos >= width){
        startTime = millis();
        scene = 4;
      } else {
        xPos ++;
      }
      //-----------------------------------------------------------------------------------------------------------------------------
    }
    
    if(scene == 4){  
    //----------------------------send signal to let arduino stop printing
    background(255);
     textFont(fontLong);
     text("Your letter is now part of the longest letter of many collective feelings.",width/2-275,height/2);
     //text("Press the button to create a letter... ",width/2-180,height/2);
     int timeLeft = millis() - startTime;
     if(timeLeft > 10000){
        scene = 5;
     }
    }
    
    if (scene == 5){ 
      background(255);
      //int timeLeft = millis() - startTime;
      //if(timeLeft < 20000){
        //text(timeLeft/1000, width/2, height/2 - 20);
        //text("Your letter is printing... ",width/2,height/2);
        textFont(fontBold);
        text("Press the button to create a letter... ",width/2-180,height/2);
        textFont(font);
      //}
      sender = new ArrayList<Character>();
      receiver = new ArrayList<Character>();
    }
}

void serialEvent(Serial thisPort){
  if(thisPort == sensorPort){
    String inString = thisPort.readStringUntil('\n');
   
  
    if(inString !=null){
      inString = trim(inString);
      println(inString);
      int reset = int(inString);
      println(reset);
      if(reset == 12385){
        println("got it!");
        scene = 1;
      }else{
        int currentSensorRate = int(inString);
    //draw
       SensorHeight = map(currentSensorRate,200,1100,50,400);  
      }
    }
  }
}


String getNameString(ArrayList<Character> name){
  String resultString = "";
  for(int i = 0; i < name.size();i++){
    char temp = name.get(i);
    String sTemp = str(temp);
    resultString += sTemp;
  }
  return resultString;
}

void keyPressed(){

  if(scene == 1 && inputCheck(key)){
    receiver.add(key);
  }
  
  if(scene == 1 && key == BACKSPACE){
    if(receiver.size() > 0){
      receiver.remove(receiver.size()-1);
    }
  }
  
   if(scene == 2 && key == BACKSPACE){
     if(sender.size() > 0){
      sender.remove(sender.size()-1);
     }
  }
  
  if(scene == 1 && key == ENTER){
    scene += 1;
    //send receiver to arduino------------------------------
    
    sensorPort.write(2);
    for(int i = 0; i < receiver.size(); i++){
      sensorPort.write(receiver.get(i));
    }
    
    //end----------------------------------------------------
   
  }else if(scene == 2 && key == ENTER){
    //send sender to arduino------------------------------
    
    sensorPort.write(3);
    for(int i = 0; i < sender.size(); i++){
      sensorPort.write(sender.get(i));
    }
    
    //end----------------------------------------------------
     scene = 9;
     delay(5000);
     sensorPort.write(1);
  }
  
  if(scene == 2 && inputCheck(key)){
    sender.add(key);
  }
  
  if(scene == 9 && key == ' '){
     background(255);
     defaultScreen();
     delay(5000);
     sensorPort.write(0);
     scene = 3;
  }
  
 
}


boolean inputCheck(Character c){
   
    if (c == 'A' || c == 'a' || c == 'B' || c == 'b' || c == 'C' || c == 'c' || c == 'D' || c == 'd' || c == 'E' || c == 'e' ||
             c == 'F' || c == 'f' || c == 'G' || c == 'g' || c == 'H' || c == 'h' || c == 'I' || c == 'i' || c == 'J' || c == 'j' ||
             c == 'K' || c == 'k' || c == 'L' || c == 'l' || c == 'M' || c == 'm' || c == 'N' || c == 'n' || c == 'O' || c == 'o' ||
             c == 'P' || c == 'p' || c == 'Q' || c == 'q' || c == 'R' || c == 'r' || c == 'S' || c == 's' || c == 'T' || c == 't' ||
             c == 'U' || c == 'u' || c == 'V' || c == 'v' || c == 'W' || c == 'w' || c == 'X' || c == 'x' || c == 'Y' || c == 'y' ||
             c == 'Z' || c == 'z' || c ==' '){
        return true;
    }else{
        return false;
    }
}


void defaultScreen(){
  if(receiverString == ""){
        text("Hey,  ________:",40,45);
      }else{
        String result = "Hey, " + receiverString;
        text(result,40,45);
      }

      
      if(senderString != " "){
        String result = "Sincerely, " + senderString;
        text(result,width-280,height-60);
      }
}
