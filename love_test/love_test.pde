import processing.serial.*;
import processing.pdf.*;

Serial sensorPort;
Serial printerPort;
PFont font;
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
  font = createFont("Roboto-Bold.ttf", 22); 
 
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
        text("Who would you like to write this letter to? ",width/2,height/2);
     }
     
     if(scene == 2){
       
       background(255);
       defaultScreen();
        text("This is a special letter for you:",40,80);
        text("And what's your name? ",width/2,height/2);
        if(senderString == " "){
          text("Sincerely,", width-370,height-80);
        }
     }
     
     
     if(scene == 9){
        background(255);
        defaultScreen();
        text("This is a special letter for you:",40,80);
        text("Put your finger on the green light sensor.",width/2,height/2 - 10);
        text("If you are ready, press SPACE and wait.",width/2,height/2 + 30);
     }
     
    if(scene == 3){
      sensorPort.write(0);
       //---------------------------------------------------------------------------------------------------drawing the diagram
      stroke(0);
      strokeWeight(10);
      float yPos = height- SensorHeight;
      float OldyPos = height- oldSensorHeight;
      line(xPos - 1, OldyPos, xPos, yPos);
      
      fill(map(SensorHeight,250,300,100,255),random(0,100),random(0,100),30);
      float r = SensorHeight/30;
      noStroke();
      ellipse(xPos, yPos+random(-8,8),r,r);
      
      oldSensorHeight = SensorHeight;
      
      if(xPos >= width){
        scene = 4;
      } else {
        xPos ++;
      }
      //-----------------------------------------------------------------------------------------------------------------------------
    }
    
    if(scene == 4){  
    //----------------------------send signal to let arduino stop printing
      scene = 5;
      //startTime = millis();
    }
    
    if (scene == 5){ 
      background(255);
      //int timeLeft = millis() - startTime;
      //if(timeLeft < 20000){
        //text(timeLeft/1000, width/2, height/2 - 20);
        //text("Your letter is printing... ",width/2,height/2);
        text("Press play button to write a letter... ",width/2,height/2);
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
       SensorHeight = map(currentSensorRate,0,1000,100,400);  
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
        text(result,width-300,height-80);
      }
}
