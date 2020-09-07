class HyperBeam {
  float xPos, yPos;
  float angle;
  float beamLength;
  float beamWidth, beamMaxWidth;
  float beamIncreaseRate, beamIncreaseAcceleration, beamDecreaseRate;
  float chargingCircleRadius, circleRadiusIncrease, maxCircleRadius;
  float boxLength;
  float collisionDistance;
  float textDuration, textTimer;
  boolean beamCharging;
  boolean beamIncreasing;
  boolean active;
  boolean dropped;
  
  HyperBeam(float fR) {
    angle = 0;
    beamLength = width;
    beamWidth = 1;
    beamMaxWidth = 200;
    beamIncreaseRate = 0.1;
    beamIncreaseAcceleration = 0.5;
    beamDecreaseRate = 3;
    chargingCircleRadius = 0.1;
    circleRadiusIncrease = 0.21;
    maxCircleRadius = 20;
    
    boxLength = 25;
    collisionDistance = (float)Math.sqrt(2*Math.pow(boxLength, 2));
    textDuration = 2*fR;
    textTimer = 0;
    beamCharging = true;
    beamIncreasing = true;
    active = false;
    dropped = false;
  }
  
  //getters
  float getX() { return xPos; }
  float getY() { return yPos; }
  float getBeamWidth() { return beamWidth; }
  float getBeamHeight() { return beamLength; }
  float getBeamAngle() { return angle; }
  boolean isCharging() { return beamCharging; }
  boolean isDropped() { return dropped; }
  boolean isActive() { return active; }
  
  void checkForShipCollision(float shipX, float shipY, float shipSize) {
    if (dropped && Math.sqrt(Math.pow(shipX-xPos, 2) + Math.pow(shipY-yPos, 2)) < shipSize/2+collisionDistance+5) {
      activate();
    }
  }
  
  //activates this upgrade's effect
  void activate() {
    active = true;
    dropped = false;
    textTimer = textDuration;
  }
  
  //spawns the drop box for this upgrade
  void drop(float x, float y) {
    dropped = true;
    xPos = x;
    yPos = y;
  }
  
  //deactivates this upgrade
  void deactivate(Ship s) {
    active = false;
    beamWidth = 1;
    beamIncreaseRate = 1;
    beamIncreasing = true;
    chargingCircleRadius = 0.1;
    beamCharging = true;
    s.setFiringBeam(false);
  }
  
  //draws the hyper beam effects
  void drawBeam(float shipX, float shipY, float shipSize, float shipAngle, Ship s) {
    if (isActive()) {
      angle = shipAngle;
      if (beamCharging) {
        xPos = 0;
        yPos = -1.5*shipSize;
        strokeWeight(2);
        stroke(255, 200, 5);
        noFill();
        translate(shipX, shipY);
        rotate(angle);
        ellipse(xPos, yPos, 2*chargingCircleRadius, 2*chargingCircleRadius);
        rotate(-angle);
        translate(-shipX, -shipY);
        
        chargingCircleRadius += circleRadiusIncrease;
        if (chargingCircleRadius > maxCircleRadius) {
          beamCharging = false;
          s.setFiringBeam(true);
        }
      } else {
        xPos = -beamWidth/2;
        yPos = -2*shipSize-beamLength;
        fill(255, 200, 5);
        noStroke();
        translate(shipX, shipY);
        rotate(angle);
        rect(xPos, yPos, beamWidth, beamLength, 12);
        rotate(-angle);
        translate(-shipX, -shipY);
        
        //making changes to beamWidth, and acting based on its current value
        if (beamIncreasing) {
          beamWidth += beamIncreaseRate;
          beamIncreaseRate += beamIncreaseAcceleration;
        }
        else { beamWidth -= beamDecreaseRate; }
        if (beamIncreasing && beamWidth > beamMaxWidth) { beamIncreasing = false; }
        if (beamWidth < 0) { deactivate(s); }
      }
      //stuff to do with text
      textTimer -= 1;
      if (textTimer > 0) { drawText(); }
    }
  }
  
  //draws the box icon for this upgrade
  void drawIcon() {
    rectMode(CENTER);
    noStroke();
    fill(130, 150, 150);
    rect(xPos, yPos, boxLength, boxLength);
    rectMode(CORNER);
    
    fill(255, 200, 5);
    textSize(20);
    textAlign(CENTER);
    text("B", xPos, yPos+boxLength/4);
  }
  
  //draws the name of this upgrade
  void drawText() {
    textSize(50);
    textAlign(CENTER);
    fill(255, 200, 5);
    text("Hyper Beam", width/2, height/6);
  }
}
