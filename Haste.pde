class Haste {
  float xPos, yPos;
  float boxLength;
  float collisionDistance;
  float textDuration, textTimer;
  boolean textShowing;
  boolean dropped;
  
  Haste(float fR) {
    boxLength = 25;
    collisionDistance = (float)Math.sqrt(2*Math.pow(boxLength, 2));
    textDuration = 2.2*fR;
    textTimer = 0;
    textShowing = false;
    dropped = false;
  }
  
  //getters
  float getX() { return xPos; }
  float getY() { return yPos; }
  boolean textShowing() { return textShowing; }
  boolean isDropped() { return dropped; }
  
  void checkForShipCollision(float shipX, float shipY, float shipSize, Ship s) {
    if (dropped && Math.sqrt(Math.pow(shipX-xPos, 2) + Math.pow(shipY-yPos, 2)) < shipSize/2+collisionDistance+5) {
      activate(s);
    }
  }
  
  //activates this upgrade's effect
  void activate(Ship s) {
    dropped = false;
    textTimer = textDuration;
    s.activateHaste();
    textShowing = true;
  }
  
  void drop(float x, float y) {
    dropped = true;
    xPos = x;
    yPos = y;
  }
  
  //draws the box icon for this upgrade
  void drawIcon() {
    rectMode(CENTER);
    noStroke();
    fill(130, 150, 150);
    rect(xPos, yPos, boxLength, boxLength);
    rectMode(CORNER);
    
    fill(200, 10, 20);
    textSize(20);
    textAlign(CENTER);
    text("H", xPos, yPos+boxLength/4);
  }
  
  //draws the name of this upgrade
  void drawText() {
    textSize(50);
    textAlign(CENTER);
    fill(200, 10, 20);
    text("Haste", width/2, height/6);
    
    textTimer -= 1;
    if (textTimer < 0) {
      textShowing = false;
      textTimer = 0;
    }
  }
}
