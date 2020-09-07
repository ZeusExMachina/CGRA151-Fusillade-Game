class Turret{
  //position and velocity
  float x, y;
  float xVel, yVel;
  float escapeSpeed;
  float forwardSpeed;
  //properties of the turret
  boolean dead;
  float circleSize;
  float maxTravelLengthOfSafeBullet;
  float angle;
  float shipMinProximity;
  float otherTurretsProximity;
  //status effects
  float frozenDuration;
  float frozenTimer;
  boolean frozen;
  
  Turret(float fR) {
    x = random(25, width-25);
    y = random(25, height-25);
    escapeSpeed = 3;
    forwardSpeed = 0.4;
    
    dead = false;
    circleSize = 25;
    maxTravelLengthOfSafeBullet = 5+circleSize*4/5;
    shipMinProximity = 100;
    otherTurretsProximity = 175;
    
    frozenDuration = 20*fR;
    frozenTimer = 0;
    frozen = false;
  }
  
  //getters
  float getX() { return x; }
  float getY() { return y; }
  float getAngle() { return angle; }
  float getDistanceForSafeBullet() { return maxTravelLengthOfSafeBullet; }
  boolean isDead() { return dead; }
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
  
  //checks for a collision with a bullet
  TurretBullet checkForBulletCollision(List<TurretBullet> bulletList) {
    for (TurretBullet b : bulletList) {
      if (b.readyToKill() && Math.sqrt(Math.pow(b.getX()-x, 2) + Math.pow(b.getY()-y, 2)) < (circleSize/2+b.getBulletSize()/2)) {
        dead = true;
        return b;
      }
    }
    return null;
  }
  
  //checks for a collision with a missile
  Missile checkForMissileCollision(List<Missile> missileList) {
    for (Missile m : missileList) {
      if (m.readyToKill() && Math.sqrt(Math.pow(m.getX()-x, 2) + Math.pow(m.getY()-y, 2)) < (circleSize/2+(m.getCollisionDistance()/2))) {
        dead = true;
        return m;
      }
    }
    return null;
  }
  
  //checks the turret against the edges of the window
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
  
  //moves this turret according to its current situation
  void doMove(List<Turret> turretList, List<MissileTurret> missileTurretList, float shipX, float shipY) {
    if (frozen) { 
      xVel = 0;
      yVel = 0;
      return;
    }
    if (Math.sqrt(Math.pow(shipX-x, 2) + Math.pow(shipY-y, 2)) < shipMinProximity) { //distance from ship calculation
      xVel = -escapeSpeed*(float)Math.cos(angle);
      yVel = -escapeSpeed*(float)Math.sin(angle);
      return;
    }
    //checking distance from other turrets
    float angleToOtherTurret;
    for (Turret t : turretList) {
      if (t != this && Math.sqrt(Math.pow(t.getX()-x, 2) + Math.pow(t.getY()-y, 2)) < otherTurretsProximity) {
        angleToOtherTurret = atan2(t.getY()-y, t.getX()-x);
        xVel = -escapeSpeed*(float)Math.cos(angleToOtherTurret);
        yVel = -escapeSpeed*(float)Math.sin(angleToOtherTurret);
        return;
      }
    }
    //checking distance from missile turrets
    for (MissileTurret t : missileTurretList) { //bullet turrets
      if (Math.sqrt(Math.pow(t.getX()-x, 2) + Math.pow(t.getY()-y, 2)) < otherTurretsProximity) {
        angleToOtherTurret = atan2(t.getY()-y, t.getX()-x);
        xVel = -escapeSpeed*(float)Math.cos(angleToOtherTurret);
        yVel = -escapeSpeed*(float)Math.sin(angleToOtherTurret);
        return;
      }
    }
    //otherwise
    xVel = forwardSpeed*(float)Math.cos(angle);
    yVel = forwardSpeed*(float)Math.sin(angle);
  }
  
  //draws the turret
  void drawTurret(float shipX, float shipY) { //draws the turret
    stroke(50);
    strokeWeight(1);
    fill(255, 0, 0);
    
    translate(x, y);
    ellipse(0, 0, circleSize, circleSize);
    
    if (!frozen) { angle = atan2(shipY-y, shipX-x); }
    rotate(angle);
    rect(5, -5, circleSize*4/5, circleSize*2/5);
    
    rotate(-angle);
    translate(-x, -y);
    
    //calculations and drawing for the 'frozen' status effect
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
}
