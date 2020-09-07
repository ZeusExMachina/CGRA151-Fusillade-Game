class TurretBullet{
  float xPos, yPos;
  float xDir, yDir;
  float speed;
  float size;
  float distanceTravelled;
  float hardModeTravelLimit;
  float distanceToActivateFriendlyFire;
  boolean bouncedBack;
  boolean friendlyFireOn;
  
  TurretBullet(float turretX, float turretY, float maxDistance) {
    xPos = turretX;
    yPos = turretY;
    speed = 3.5;
    size = 7;
    distanceTravelled = 0;
    hardModeTravelLimit = 1700;
    distanceToActivateFriendlyFire = size/2 + 2 + maxDistance;
    bouncedBack = false;
    friendlyFireOn = false;
  }
  
  //getters
  float getX() { return xPos; }
  float getY() { return yPos; }
  float getXDir() { return xDir; }
  float getYDir() { return yDir; }
  float getBulletSize() { return size; }
  boolean alreadyBounced() { return bouncedBack; }
  boolean readyToKill() { return friendlyFireOn; }
  
  //setters
  void setToBouncedBack() { bouncedBack = true; }
  //sets the x and y speeds of the bullet depending on the angle of the turret's muzzle
  void setSpeeds(float xD, float yD) {
    xDir = xD;
    yDir = yD;
  }
  
  //directly inverts the x and y speed values of the bullet
  void invertSpeeds() {
    xDir = -xDir;
    yDir = -yDir;
  }
  
  //shifts the position of this bullet
  void shift(float x, float y) {
    xPos += x;
    yPos += y;
  }
  
  //checks if bullet has travelled farther than the set travel limit
  boolean isPastTravelLimit() {
    return distanceTravelled > hardModeTravelLimit;
  }
  
  //checks if the bullet is past the boundaries of the game (defined by the window size)
  boolean isPastBoundary() {
    return xPos < 0 || xPos > width || yPos < 0 || yPos > height;
  }
  
  void deflectOffBoundary() {
    if (xPos < 0 || xPos > width) { xDir = -xDir; }
    if (yPos < 0 || yPos > height) { yDir = -yDir; }
  }
  
  //draws the bullet
  void drawBullet(boolean hardMode) {
    noStroke();
    if (bouncedBack) { fill(10, 225, 225); }
    else { fill(235); }
    
    if (hardMode) { speed = 6;}
    else { speed = 3.5; }
    
    ellipse(xPos, yPos, size, size);
    xPos += xDir*speed;
    yPos += yDir*speed;
    distanceTravelled += Math.sqrt(Math.pow(xDir*speed, 2) + Math.pow(yDir*speed, 2));
    if (!friendlyFireOn && distanceTravelled > distanceToActivateFriendlyFire) { friendlyFireOn = true; }
  }
}
