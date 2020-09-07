class MissileTurret{
  //position and velocity
  float x, y;
  float xVel, yVel;
  float turretAngle;
  float angleThreshold;
  float turnSpeed;
  float escapeSpeed;
  float forwardSpeed;
  //properties of the turret
  boolean dead;
  float circleSize;
  float maxTravelLengthOfSafeBullet;
  float shipAngle;
  float shipMinProximity;
  float otherTurretsProximity;
  //status effects
  float frozenDuration;
  float frozenTimer;
  boolean frozen;
  
  MissileTurret(float fR) {
    x = random(25, width-25);
    y = random(25, height-25);
    //turretAngle = random(0, TWO_PI);
    turretAngle = 0;
    angleThreshold = 3*PI/180;
    
    turnSpeed = 0.003;
    escapeSpeed = 3;
    forwardSpeed = 0.4;
    
    dead = false;
    circleSize = 25;
    maxTravelLengthOfSafeBullet = 35+circleSize*4/5;
    shipMinProximity = 100;
    otherTurretsProximity = 175;
    
    frozenDuration = 20*fR;
    frozenTimer = 0;
    frozen = false;
  }
  
  //getters
  float getX() { return x; }
  float getY() { return y; }
  float getAngle() { return turretAngle; }
  float getDistanceForSafeBullet() { return maxTravelLengthOfSafeBullet; }
  boolean isDead() { return dead; }
  boolean isFacingShip() { return !(turretAngle > shipAngle+angleThreshold || turretAngle < shipAngle-angleThreshold); }
  boolean isFrozen() { return frozen; }
  
  //applies the 'frozen' status effect on this turret
  void freeze() {
    frozen = true;
    frozenTimer = frozenDuration;
  }
  
  //shifts the turret by the amounts given
  void shiftTurret(float xDiff, float yDiff) {
    x += xDiff;
    y += yDiff;
  }
  
  //checks for bullet collision
  TurretBullet checkForBulletCollision(List<TurretBullet> bulletList) {
    for (TurretBullet b : bulletList) {
      if (b.readyToKill() && Math.sqrt(Math.pow(b.getX()-x, 2) + Math.pow(b.getY()-y, 2)) < (circleSize/2+b.getBulletSize()/2)) {
        dead = true;
        return b;
      }
    }
    return null;
  }
  
  //checks for missile collision
  Missile checkForMissileCollision(List<Missile> missileList) {
    for (Missile m : missileList) {
      if (m.readyToKill() && Math.sqrt(Math.pow(m.getX()-x, 2) + Math.pow(m.getY()-y, 2)) < (circleSize/2+m.getCollisionDistance()/2)) {
        dead = true;
        return m;
      }
    }
    return null;
  }
  
  void checkForBoundaries() {
    if (x < circleSize/2) {
      x = circleSize/2;
      xVel = 0;
    } else if (x > width-circleSize/2) {
      x = width-circleSize/2;
      xVel = 0;
    }
    if (y < circleSize/2) {
      y = circleSize/2;
      yVel = 0;
    } else if (y > height-circleSize/2) {
      y = height-circleSize/2;
      yVel = 0;
    }
  }
  
  void doMove(List<Turret> turretList, List<MissileTurret> missileTurretList, float shipX, float shipY) {
    if (frozen) { 
      xVel = 0;
      yVel = 0;
      return;
    }
    if (Math.sqrt(Math.pow(shipX-x, 2) + Math.pow(shipY-y, 2)) < shipMinProximity) { //distance from ship calculation
      xVel = -escapeSpeed*(float)Math.cos(turretAngle);
      yVel = -escapeSpeed*(float)Math.sin(turretAngle);
      return;
    }
    //checking distance from bullet turrets
    float angleToOtherTurret;
    for (Turret t : turretList) { //bullet turrets
      if (Math.sqrt(Math.pow(t.getX()-x, 2) + Math.pow(t.getY()-y, 2)) < otherTurretsProximity) {
        angleToOtherTurret = atan2(t.getY()-y, t.getX()-x);
        xVel = -escapeSpeed*(float)Math.cos(angleToOtherTurret);
        yVel = -escapeSpeed*(float)Math.sin(angleToOtherTurret);
        return;
      }
    }
    //checking distance from other missile turrets
    for (MissileTurret t : missileTurretList) {
      if (t != this && Math.sqrt(Math.pow(t.getX()-x, 2) + Math.pow(t.getY()-y, 2)) < otherTurretsProximity) {
        angleToOtherTurret = atan2(t.getY()-y, t.getX()-x);
        xVel = -escapeSpeed*(float)Math.cos(angleToOtherTurret);
        yVel = -escapeSpeed*(float)Math.sin(angleToOtherTurret);
        return;
      }
    }
    //otherwise
    if (isFacingShip()) {
      xVel = forwardSpeed*(float)Math.cos(turretAngle);
      yVel = forwardSpeed*(float)Math.sin(turretAngle);
    }
  }
  
  //drawing the turret
  void drawTurret(float shipX, float shipY) {
    stroke(50);
    strokeWeight(1);
    fill(230, 120, 0);
    
    translate(x, y);
    ellipse(0, 0, circleSize, circleSize);
    
    //shipAngle and turretAngle's initially calculated values are not aligned with each other, so must be adjusted
    shipAngle = atan2(shipY-y, shipX-x);
    if (shipAngle < 0) { shipAngle += TWO_PI; }
    if (!isFacingShip()) {
      if (turretAngle < 0) { turretAngle += TWO_PI; }
      if (turretAngle > TWO_PI) { turretAngle -= TWO_PI; }
      if (!frozen) { turnInADirection(); }
    }
    
    rotate(turretAngle);
    rect(5, -5, circleSize*4/5, circleSize*2/5);
    
    rotate(-turretAngle);
    translate(-x, -y);
    
    //frozen visual status effect
    if (frozen) {
      strokeWeight(2);
      stroke(140, 230, 240);
      fill(100, 190, 200);
      ellipse(x, y, circleSize*1.5, circleSize*1.5);
      
      frozenTimer -= 1;
      if (frozenTimer <= 0) {
        frozen = false;
        frozenTimer = frozenDuration;
      }
    }
    
    checkForBoundaries();
    x += xVel;
    y += yVel;
  }
  
    void turnInADirection() {
    if (turretAngle >= 0 && turretAngle < PI) {
      if (shipAngle <= turretAngle+PI && shipAngle > turretAngle) { turretAngle += turnSpeed*PI; }
      else { turretAngle -= turnSpeed*PI; }
    } else {
      if (shipAngle >= turretAngle-PI && shipAngle < turretAngle) { turretAngle -= turnSpeed*PI; }
      else { turretAngle += turnSpeed*PI; }
    }
  }
}
