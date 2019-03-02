import processing.serial.*;
import processing.pdf.*;

Serial myPort;
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
headerGenerator hg;

void setup(){
  size(800,480);
  //fullScreen();
  font = createFont("Roboto-Bold.ttf", 22); 
  hg = new headerGenerator();
  sender = new ArrayList<Character>();
  receiver = new ArrayList<Character>();
  background(255);
  frameRate(60);
   
  //println(Serial.list());
  //String Sensor = Serial.list()[2];
  myPort = new Serial(this,Serial.list()[4],115200);
  
}



void draw(){
       //whit boxes
    //fill(255);
    //noStroke();
    //rect(0,0,width, 40);
    //rect(0,0,width, height-40);
      //text
    
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
    if(scene == 3){
      
    
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
      //xPos ++;
      
      if(xPos >= width){
        scene = 4;
      } else {
        xPos ++;
      }
      //-----------------------------------------------------------------------------------------------------------------------------

    }
    
    if(scene == 4){
      println(scene);
      saveImage();
      hg.generateHeader();
      delay(5000);
      scene = 5;
    }
    
    if (scene ==5){  
      
      background(255);
      text("Your letter is printing... ",width/2,height/2);
      text("Press space to write a letter. ",width/2,height/2+40);
      sender = new ArrayList<Character>();
      receiver = new ArrayList<Character>();

    }
  
}

void serialEvent(Serial myPort){
  String inString = myPort.readStringUntil('\n');
  
  if(inString !=null){
    inString = trim(inString);
    //println(inString);
    int currentSensorRate = int(inString);
    //println(currentSensorRate);    
  
    //draw
   SensorHeight = map(currentSensorRate,0,1000,100,400);  
   //println(SensorHeight); 
   
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
    println("delete");
    receiver.remove(receiver.size()-1);
  }
  
   if(scene == 2 && key == BACKSPACE){
    sender.remove(sender.size()-1);
  }
  
  if(scene == 1 && key == ENTER){
    scene += 1;
    println(scene);
  }else if(scene == 2 && key == ENTER){
     scene += 1;
     background(255);
     defaultScreen();
     println(scene);
  }
  
  if(scene == 2 && inputCheck(key)){
    sender.add(key);
  }
  
  if(scene == 5 && key == ' '){
    scene =1;
    println(scene);
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

void saveImage(){
  save("here.png");
  PImage graphPrev = loadImage("here.png");
  PImage graphNew = graphPrev.get();
  graphNew.resize(350,218);
  graphNew.save("data/graphNew.png"); 
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
