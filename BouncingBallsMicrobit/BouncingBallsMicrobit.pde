import processing.serial.*; 
import java.awt.event.KeyEvent;
import java.io.IOException;

Serial mySerial;

Ball[] balls =  { 
  new Ball(100, 400, 20),
  new Ball(400, 400, 40),
  new Ball(700, 400, 60) 
};
Ball myBall = new Ball(1000, 600, 80);
color bg;

void setup() {
  size(1280, 720);
  colorMode(RGB, 100);
  mySerial = new Serial(this, "/dev/cu.usbmodem14202", 115200);
  mySerial.bufferUntil('.');
}

void draw() {
  background(51);

  for (Ball b : balls) {
    b.update();
    b.display();
    b.checkBoundaryCollision();
  }
  
  
  myBall.update();
  myBall.display();
  myBall.checkBoundaryCollision();
 
  for(int i = 0; i < 3; i++){
    balls[i].checkCollision(myBall);
    for (int k=i+1; k < 3; k++){
      balls[i].checkCollision(balls[k]);
    }
  }
}







class Ball {
  PVector position;
  PVector velocity;

  float radius, m;
  float red, green, blue;
  color ballColor;

  Ball(float x, float y, float r_) {
    position = new PVector(x, y);
    velocity = PVector.random2D();
    velocity.mult(3);
    radius = r_;
    m = radius*.1;
    red = random(255); // HSB Color Mode
    green = random(255);
    blue = random(255);
    
  }

  void update() {
    position.add(velocity);
  }

  void checkBoundaryCollision() {
    if (position.x > width-radius) {
      position.x = width-radius;
      velocity.x *= -1;
    } else if (position.x < radius) {
      position.x = radius;
      velocity.x *= -1;
    } else if (position.y > height-radius) {
      position.y = height-radius;
      velocity.y *= -1;
    } else if (position.y < radius) {
      position.y = radius;
      velocity.y *= -1;
    }
  }

  void checkCollision(Ball other) {

    // Get distances between the balls components
    PVector distanceVect = PVector.sub(other.position, position);

    // Calculate magnitude of the vector separating the balls
    float distanceVectMag = distanceVect.mag();

    // Minimum distance before they are touching
    float minDistance = radius + other.radius;

    if (distanceVectMag < minDistance) {
      float distanceCorrection = (minDistance-distanceVectMag)/2.0;
      PVector d = distanceVect.copy();
      PVector correctionVector = d.normalize().mult(distanceCorrection);
      other.position.add(correctionVector);
      position.sub(correctionVector);

      // get angle of distanceVect
      float theta  = distanceVect.heading();
      // precalculate trig values
      float sine = sin(theta);
      float cosine = cos(theta);

      /* bTemp will hold rotated ball positions. You 
       just need to worry about bTemp[1] position*/
      PVector[] bTemp = {
        new PVector(), new PVector()
      };

      /* this ball's position is relative to the other
       so you can use the vector between them (bVect) as the 
       reference point in the rotation expressions.
       bTemp[0].position.x and bTemp[0].position.y will initialize
       automatically to 0.0, which is what you want
       since b[1] will rotate around b[0] */
      bTemp[1].x  = cosine * distanceVect.x + sine * distanceVect.y;
      bTemp[1].y  = cosine * distanceVect.y - sine * distanceVect.x;

      // rotate Temporary velocities
      PVector[] vTemp = {
        new PVector(), new PVector()
      };

      vTemp[0].x  = cosine * velocity.x + sine * velocity.y;
      vTemp[0].y  = cosine * velocity.y - sine * velocity.x;
      vTemp[1].x  = cosine * other.velocity.x + sine * other.velocity.y;
      vTemp[1].y  = cosine * other.velocity.y - sine * other.velocity.x;

      /* Now that velocities are rotated, you can use 1D
       conservation of momentum equations to calculate 
       the final velocity along the x-axis. */
      PVector[] vFinal = {  
        new PVector(), new PVector()
      };

      // final rotated velocity for b[0]
      vFinal[0].x = ((m - other.m) * vTemp[0].x + 2 * other.m * vTemp[1].x) / (m + other.m);
      vFinal[0].y = vTemp[0].y;

      // final rotated velocity for b[0]
      vFinal[1].x = ((other.m - m) * vTemp[1].x + 2 * m * vTemp[0].x) / (m + other.m);
      vFinal[1].y = vTemp[1].y;

      // hack to avoid clumping
      bTemp[0].x += vFinal[0].x;
      bTemp[1].x += vFinal[1].x;

      /* Rotate ball positions and velocities back
       Reverse signs in trig expressions to rotate 
       in the opposite direction */
      // rotate balls
      PVector[] bFinal = { 
        new PVector(), new PVector()
      };

      bFinal[0].x = cosine * bTemp[0].x - sine * bTemp[0].y;
      bFinal[0].y = cosine * bTemp[0].y + sine * bTemp[0].x;
      bFinal[1].x = cosine * bTemp[1].x - sine * bTemp[1].y;
      bFinal[1].y = cosine * bTemp[1].y + sine * bTemp[1].x;

      // update balls to screen position
      other.position.x = position.x + bFinal[1].x;
      other.position.y = position.y + bFinal[1].y;

      position.add(bFinal[0]);

      // update velocities
      velocity.x = cosine * vFinal[0].x - sine * vFinal[0].y;
      velocity.y = cosine * vFinal[0].y + sine * vFinal[0].x;
      other.velocity.x = cosine * vFinal[1].x - sine * vFinal[1].y;
      other.velocity.y = cosine * vFinal[1].y + sine * vFinal[1].x;
    }
  }

  void display() {
    noStroke();
    colorMode(RGB,100);
    fill(red,green,blue);
    ellipse(position.x, position.y, radius*2, radius*2);
  }
}

void serialEvent (Serial mySerial) {
    String data = mySerial.readStringUntil('.');
    if (data != null){
      data = data.substring(0,data.length()-1);
      int index = data.indexOf(",");
      String acc_x = data.substring(0, index);
      String acc_y = data.substring(index+1,data.length());
      int acceleration_x = int(acc_x);
      int acceleration_y = int(acc_y);
      float ball_acc_x = map(acceleration_x, 0, 1023, 0, 1);
      float ball_acc_y = map(acceleration_y, 0, 1023, 0, 1);
      print("acc_x: ");
      println(acceleration_x);
      print("acc_y: ");
      println(acceleration_y);
      PVector acceleration = new PVector(ball_acc_x, ball_acc_y);
      myBall.velocity.add(acceleration);
     
     
    }
 }
