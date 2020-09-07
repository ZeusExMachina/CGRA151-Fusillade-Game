class FreezeField {
  float xPos, yPos;
  float radius;
  float boxLength;
  float collisionDistance;
  float turretCollisionThreshold;
  float duration, timer;
  float textDuration, textTimer;
  boolean active;
  boolean dropped;
  
  FreezeField(float fR) {
    radius = 0;
    boxLength = 25;
    collisionDistance = (float)Math.sqrt(2*Math.pow(boxLength, 2));
    turretCollisionThreshold = 3;
    duration = 1.7*fR;
    timer = 0;
    textDuration = 2*fR;
    textTimer = 0;
    active = false;
    dropped = false;
  }
  
  //getters
  float getX() { return xPos; }
  float getY() { return yPos; }
  float getRadius() { return radius; }
  float getTurretCollThreshold() { return turretCollisionThreshold; }
  boolean isDropped() { return dropped; }
  boolean isActive() { return active; }
  
  //checks for if the ship is close enough to this upgrade's icon
  void checkForShipCollision(float shipX, float shipY, float shipSize) {
    if (dropped && Math.sqrt(Math.pow(shipX-xPos, 2) + Math.pow(shipY-yPos, 2)) < shipSize/2+collisionDistance+5) {
      activate();
    }
  }
  
  //activates this upgrade's effect
  void activate() {
    active = true;
    dropped = false;
    timer = duration;
    textTimer = textDuration;
  }
  
  //spawns the drop box for this upgrade
  void drop(float x, float y) {
    dropped = true;
    xPos = x;
    yPos = y;
  }
  
  //draws the freezing field effects
  void drawFreezeField() {
    if (isActive()) {
      strokeWeight(5);
      stroke(140, 230, 240);
      noFill();
      ellipse(xPos, yPos, 2*radius, 2*radius);
      radius += 4.5;
      timer -= 1;
      textTimer -= 1;
      if (textTimer > 0) { drawText(); }
      if (timer <= 0) {
        active = false;
        timer = 0;
        radius = 0;
      }
    }
  }
  
  //draws the box icon for this upgrade
  void drawIcon() {
    rectMode(CENTER);
    noStroke();
    fill(130, 150, 150);
    rect(xPos, yPos, boxLength, boxLength);
    rectMode(CORNER);
    
    fill(140, 230, 240);
    textSize(20);
    textAlign(CENTER);
    text("F", xPos, yPos+boxLength/4);
  }
  
  //draws the name of this upgrade
  void drawText() {
    textSize(50);
    textAlign(CENTER);
    fill(140, 230, 240);
    text("Freezing Field", width/2, height/6);
  }
}
