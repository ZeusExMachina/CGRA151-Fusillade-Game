class ViolentTwister {
  float xPos, yPos;
  float radius;
  float maxRadius;
  float singularityRad;
  float radiusIncreaseRate, radiusDecreaseRate;
  float angle;
  float angleChange;
  float influenceOnTurrets;
  float influenceIncrease;
  float boxLength;
  float collisionDistance;
  float[] curveVerticesX, curveVerticesY;
  float textDuration, textTimer;
  boolean radiusIncreasing;
  boolean active;
  boolean dropped;
  
  ViolentTwister(float fR) {
    radius = 1;
    radiusIncreaseRate = 1.8;
    radiusDecreaseRate = 16;
    maxRadius = 375;
    singularityRad = 25;
    angle = 0;
    angleChange = TWO_PI/radius;
    influenceOnTurrets = 0;
    influenceIncrease = 7;
    boxLength = 25;
    collisionDistance = (float)Math.sqrt(2*Math.pow(boxLength, 2));
    textDuration = 2.2*fR;
    textTimer = 0;
    radiusIncreasing = true;
    active = false;
    dropped = false;
    
    curveVerticesX = new float[4]; curveVerticesY = new float[4];
    curveVerticesX[0] = 10; curveVerticesY[0] = 20;
    curveVerticesX[1] = 0; curveVerticesY[1] = 10;
    curveVerticesX[2] = 0; curveVerticesY[2] = 0;
    curveVerticesX[3] = 10; curveVerticesY[3] = -10;
  }
  
  //getters
  float getX() { return xPos; }
  float getY() { return yPos; }
  float getGravitationalInfluence() { return influenceOnTurrets; }
  float getSingularityRadius() { return singularityRad; }
  boolean isDropped() { return dropped; }
  boolean isActive() { return active; }
  
  //checks for if the ship is close enough to this upgrade's icon
  void checkForShipCollision(float shipX, float shipY, float shipSize) {
    if (dropped && Math.sqrt(Math.pow(shipX-xPos, 2) + Math.pow(shipY-yPos, 2)) < shipSize/2+collisionDistance+5) {
      activate(shipX, shipY);
    }
  }
  
  //activates this upgrade's effect
  void activate(float shipX, float shipY) {
    xPos = random(125, width-125);
    if (Math.abs(xPos-shipX) < 300) { xPos = random(125, width-125); }
    yPos = random(125, height-125);
    if (Math.abs(yPos-shipY) < 300) { yPos = random(125, height-125); }
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
  void deactivate() {
    active = false;
    radius = 1;
    radiusIncreasing = true;
    influenceOnTurrets = 0;
  }
  
  //draws the violent twister effects
  void drawTwister() {
    if (isActive()) {
      //drawing
      fill(55, 10, 90);
      noStroke();
      translate(xPos, yPos);
      rotate(angle);
      ellipse(0, 0, 2*radius, 2*radius);
      stroke(170, 55, 240);
      strokeWeight(3);
      noFill();
      for (int i = 0; i < 4; i++) {
        curve(curveVerticesX[0]*radius, curveVerticesY[0]*radius, curveVerticesX[1]*radius, curveVerticesY[1]*radius, curveVerticesX[2]*radius, curveVerticesY[2]*radius, curveVerticesX[3]*radius, curveVerticesY[3]*radius);
        rotate(HALF_PI);
      }
      rotate(-angle);
      translate(-xPos, -yPos);
      
      //making changes to the radius, and acting based on its current value
      if (radiusIncreasing) { radius += radiusIncreaseRate; }
      else { radius -= radiusDecreaseRate; }
      if (radiusIncreasing && radius > maxRadius) { radiusIncreasing = false; }
      if (radius < 0) { deactivate(); }
      //angles
      angleChange = TWO_PI/radius;
      angle += angleChange;
      influenceOnTurrets += influenceIncrease;
      //stuff with the text
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
    
    fill(150, 40, 220);
    textSize(20);
    textAlign(CENTER);
    text("T", xPos, yPos+boxLength/4);
  }
  
  //draws the name of this upgrade
  void drawText() {
    textSize(50);
    textAlign(CENTER);
    fill(150, 40, 220);
    text("Violent Twister", width/2, height/6);
  }
}
