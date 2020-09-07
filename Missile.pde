class Missile {
  float xPos, yPos;
  float angle;
  float xVel, yVel;
  float initialXVertices[], initialYVertices[];
  float actualXVertices[], actualYVertices[];
  float velMult;
  float acceleration;
  float turnSpeed;
  float angleThreshold;
  float shipAngle;
  float distanceTravelled;
  float distanceToActivateFriendlyFire;
  boolean bouncedBack;
  boolean friendlyFireOn;
  
  Missile(float turretX, float turretY, float turretAngle, float maxDistance) {
    xPos = turretX;
    yPos = turretY;
    angle = turretAngle;
    xVel = (float)Math.cos(angle);
    yVel = (float)Math.sin(angle);
    initialXVertices = new float[3]; initialYVertices = new float[3];
    initialXVertices[0] = 0; initialYVertices[0] = 7;
    initialXVertices[1] = 15; initialYVertices[1] = 0;
    initialXVertices[2] = 0; initialYVertices[2] = -7;
    
    velMult = 0.05;
    turnSpeed = 0.007;
    angleThreshold = 2.5*PI/180;
    distanceTravelled = 0;
    distanceToActivateFriendlyFire = maxDistance + (initialXVertices[1]-initialXVertices[0]) + 2;
    bouncedBack = false;
    friendlyFireOn = false;
  }
  
  //getters
  float getX() { return xPos; }
  float getY() { return yPos; }
  float getCollisionDistance() { return initialYVertices[0]-initialYVertices[2]; }
  boolean isFacingShip() { return !(angle > shipAngle+angleThreshold || angle < shipAngle-angleThreshold); }
  boolean isPastBoundary() { return xPos < 0 || xPos > width || yPos < 0 || yPos > height; }
  boolean alreadyBounced() { return bouncedBack; }
  boolean readyToKill() { return friendlyFireOn; }
  
  //setters
  void setToBouncedBack() { bouncedBack = true; }
  
  //adjusts the angle by PI radians
  void invertAngle() { 
    angle += PI;
    if (angle < 0) { angle += TWO_PI; }
    if (angle > TWO_PI) { angle -= TWO_PI; }
  }
  
  //shifts the position of this missile
  void shift(float x, float y) {
    xPos += x;
    yPos += y;
  }
  
  void drawMissile(float shipX, float shipY, boolean hardMode) {
    noStroke();
    fill(235);
    
    translate(xPos, yPos);
    
    shipAngle = atan2(shipY-yPos, shipX-xPos);
    if (shipAngle < 0) { shipAngle += TWO_PI; }
    if (!isFacingShip()) {
      if (angle < 0) { angle += TWO_PI; }
      if (angle > TWO_PI) { angle -= TWO_PI; }
      turnInADirection();
    }
    
    rotate(angle);
    triangle(initialXVertices[0], initialYVertices[0], initialXVertices[1], initialYVertices[1], initialXVertices[2], initialYVertices[2]);
    
    rotate(-angle);
    translate(-xPos, -yPos);
    
    if(hardMode) { acceleration = 0.015; }
    else { acceleration = 0.0075; }
    
    velMult += acceleration;
    xVel = (float)Math.cos(angle) * velMult;
    yVel = (float)Math.sin(angle) * velMult;
    xPos += xVel;
    yPos += yVel;
    distanceTravelled += (float)Math.sqrt(Math.pow(xVel, 2) + Math.pow(yVel, 2));
    if (!friendlyFireOn && distanceTravelled > distanceToActivateFriendlyFire) { friendlyFireOn = true; }
  }
  
  void turnInADirection() {
    if (angle >= 0 && angle < PI) {
      if (shipAngle <= angle+PI && shipAngle > angle) { angle += turnSpeed*PI; }
      else { angle -= turnSpeed*PI; }
    } else {
      if (shipAngle >= angle-PI && shipAngle < angle) { angle -= turnSpeed*PI; }
      else { angle += turnSpeed*PI; }
    }
  }
}
