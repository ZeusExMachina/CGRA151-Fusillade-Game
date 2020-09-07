class SmokeCircle {
  float xPos, yPos;
  float initalAngle;
  float size;
  float smokeShade;

  SmokeCircle(float x, float y, float theta) {
    xPos = x;
    yPos = y;
    size = 8;
    initalAngle = theta;
    smokeShade = 255;
  }
  
  //gets the shade of this smoke circle
  float getShade() {
    return smokeShade;
  }
  
  //darkens the shade of this smoke circle
  void darkenShade() {
    smokeShade -= 51;
  }
  
  //draws the SmokeCircle
  void drawSmoke() {
    fill(smokeShade);
    noStroke();
    translate(xPos, yPos);
    
    ellipse(0, 0, size, size);
    
    translate(-xPos, -yPos);
  }
}
