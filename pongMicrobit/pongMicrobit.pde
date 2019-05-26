import processing.serial.*; 
import java.awt.event.KeyEvent;
import java.io.IOException;

Serial mySerial;

Ball ball = new Ball(640, 360, 20);
Paddle paddle1 = new Paddle(50, 360, 10, 90, "Player 1");
Paddle paddle2 = new Paddle(1230, 360, 10, 90, "Player 2");

void setup(){
  size(1280, 720);
  mySerial = new Serial(this, "/dev/cu.usbmodem14202", 115200);
  mySerial.bufferUntil(',');
  }

void draw(){
  background(0,0,255);
  ball.update();
  ball.checkBoundaries();
  ball.display();
  
  //SerialEvent(mySerial);
  paddle1.update();
  paddle1.display();
  
  paddle2.update();
  paddle2.display();

  
}


 void keyPressed(){
   if (key == 'a'){
     paddle1.position.sub(paddle1.move);
   }
   if (key == 'z'){
     paddle1.position.add(paddle1.move);
   }
   
   if (key == CODED){
     if (keyCode == UP){
       paddle2.position.sub(paddle2.move);
     }
     
    if (keyCode == DOWN){
       paddle2.position.add(paddle2.move);
    }
   }
 }

 void serialEvent (Serial mySerial) {
    String data = mySerial.readStringUntil(',');
    //println(data); // In order to see the difference between char and string, a and z commands are captured differently from serial.
    if (data != null){
      char command = data.charAt(data.length()-2);
      data = data.substring(0,data.length()-1);
      //println("data: " +data);
      //println("command: "+command);
      if (command == 'a'){
        paddle1.position.sub(paddle1.move);
      }
      if (data.equals("z")){
        paddle1.position.add(paddle1.move);
      }
    }
 }
class Ball {
  // Ball
  PVector position;
  PVector velocity;
  float radius;
  
  Ball(float x, float y, float r){
   position = new PVector(x,y);
   float v_x = 1;
   float v_y = random(0,1)*2 -1; 
   velocity = new PVector(v_x, v_y);
   velocity.mult(3.1);
   radius = r;
  }
  void reset(){
    position.x = 640;
    position.y = 360;
    float v_x = 1;
    float v_y = random(0,1)*2 -1; 
    velocity.x = v_x;
    velocity.y = v_y;
    velocity.mult(3.1);
  }
  void update(){
    position.add(velocity);
    if (colliding(paddle1) || colliding(paddle2)){
      velocity.x = velocity.x *(-1);
    }
    if (position.x > 1240){
      paddle1.score +=1;
      reset();
      
    }
    if (position.x < 50){
      paddle2.score +=1;
      reset();
    }
    
    if (paddle1.score >= 3 || paddle2.score >= 3 ){
      velocity.x = 0;
      velocity.y = 0;
      position.y = 20;
      if (paddle1.score > paddle2.score){
        textSize(64);
        text("Player 1 won!", 360, 360);
        }
      else{
        textSize(128);
        text("Player 2 won!", 360, 360);
      }
    }
  }

  void display(){
    noStroke();
    fill(0, 255,0);
    ellipse(position.x, position.y, radius, radius);
    
    
    
    textSize(32);
    text("Player 1: "+paddle1.score, 100, 30);
    text("Player 2: "+paddle2.score, 900, 30);
  }
  
  void checkBoundaries(){
    if (position.y < 0 || position.y > 720){
      velocity.y = velocity.y*(-1);
    }
  }
  
  boolean colliding(Paddle paddle){
    
    if ((paddle.position.x < position.x) && (position.x < (paddle.position.x+paddle.size.x)) && (paddle.position.y < position.y) && (position.y < (paddle.position.y+paddle.size.y)) ){
      return true;
    } 
    return false;
  }
}

class Paddle{
  PVector position;
  PVector size;
  float baddle_width;
  float baddle_height;
  PVector move = new PVector(0, 15);
  
  String name;
  int score = 0;
  
  Paddle(float x, float y, float b_width, float b_height, String player){
  position = new PVector(x,y);
  size = new PVector(b_width, b_height);
  
  name = player;
  }
  void update(){
    if (position.y < 0){
      position.y = 0;
    }
    if (position.y > 630){
      position.y = 630;
    }
  }
  void display(){
    noStroke();
    fill(255,0,0);
    rect(position.x, position.y, size.x, size.y);
  }
 
}
