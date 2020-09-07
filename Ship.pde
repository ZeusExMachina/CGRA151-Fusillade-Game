class Ship {
  //position and direction
  float xPos, yPos; 
  float xVel, yVel;
  float angle;
  float mouseAngle;
  //properties and speeds
  boolean alive;
  boolean moving;
  float size;
  float moveSpeed;
  float turnSpeed;
  float nitroAndShieldRadius;
  float[] initialBoxCoordsX, initialBoxCoordsY;
  float[] boxCoordsX, boxCoordsY;
  PVector[] boxCoordVectors;
  //fields to do with the nitro boost
  boolean nitroOn;
  float nitroSpeed;
  float nitroMaxDuration;
  float nitroDurationTimer;
  float nitroBarMaxHalfLength;
  float nitroBarLength;
  //fields to do with the warp ability
  float warpSpeed;
  float warpCooldown;
  float warpEnergy;
  float warpBarMaxHalfLength;
  float warpBarLength;
  //status effects
  float hasteDuration;
  float hasteTimer;
  boolean hasted;
  boolean firingBeam;
  //other objects related to the ship
  Shield shield;
  List<SmokeCircle> smokeClouds;
  Set<SmokeCircle> smokesToRemove;

  Ship(float frameR) {
    xPos = width/2;
    yPos = height/2;
    xVel = 0;
    yVel = 0;
    angle = 0;
    mouseAngle = 0;
    
    alive = true;
    size = 23.0;
    moveSpeed = 3.5;
    turnSpeed = 3.5*PI/180;
    nitroAndShieldRadius = 100;
    
    initialBoxCoordsX = new float[5]; initialBoxCoordsY = new float[5];
    boxCoordsX = new float[5]; boxCoordsY = new float[5];
    boxCoordVectors = new PVector[5];
    initialBoxCoordsX[0] = -size/2; initialBoxCoordsY[0] = -size/2;
    initialBoxCoordsX[1] = size/2; initialBoxCoordsY[1] = -size/2;
    initialBoxCoordsX[2] = -size/2-size/4; initialBoxCoordsY[2] = 5*size/4;
    initialBoxCoordsX[3] = size/2+size/4; initialBoxCoordsY[3] = 5*size/4;
    initialBoxCoordsX[4] = 0; initialBoxCoordsY[4] = -1.5*size;
    boxCoordsX[0] = xPos+initialBoxCoordsX[0]; boxCoordsY[0] = yPos+initialBoxCoordsY[0];
    boxCoordsX[1] = xPos+initialBoxCoordsX[1]; boxCoordsY[1] = yPos+initialBoxCoordsY[1];
    boxCoordsX[2] = xPos+initialBoxCoordsX[2]; boxCoordsY[2] = yPos+initialBoxCoordsY[2];
    boxCoordsX[3] = xPos+initialBoxCoordsX[3]; boxCoordsY[3] = yPos+initialBoxCoordsY[3];
    boxCoordsX[4] = xPos+initialBoxCoordsX[4]; boxCoordsY[4] = yPos+initialBoxCoordsY[4];
    
    nitroSpeed = 8;
    nitroMaxDuration = 1.8*frameR;
    nitroDurationTimer = nitroMaxDuration;
    nitroBarMaxHalfLength = 0.375*QUARTER_PI;
    nitroBarLength = nitroBarMaxHalfLength;
    
    warpSpeed = 170;
    warpCooldown = 5*frameR;
    warpEnergy = warpCooldown;
    warpBarMaxHalfLength = 0.375*QUARTER_PI;
    warpBarLength = warpBarMaxHalfLength;
    
    hasteDuration = 10*frameR;
    hasteTimer = 0;
    hasted = false;
    firingBeam = false;
    
    shield = new Shield(xPos, yPos, nitroAndShieldRadius, frameR);
    smokeClouds = new ArrayList<SmokeCircle>();
    smokesToRemove = new HashSet<SmokeCircle>();
  }
  
  //getters
  float getX() { return xPos; }
  float getY() { return yPos; }
  float getSize() { return size; }
  float getAngle() { return angle; }
  boolean isAlive() { return alive; }
  boolean isHasted() { return hasted; }
  Shield getShield() { return shield; }
  
  //setters
  void activateNitro() { if (nitroDurationTimer == nitroMaxDuration) { nitroOn = true; } }
  void setFiringBeam(boolean state) { firingBeam = state; }
  
  //if the ship is in the middle of an active Violent Twister, it just spins
  void spinInSingularity(float shipX, float shipY) {
    angle += QUARTER_PI;
    xPos = shipX;
    yPos = shipY;
  }
  
  //warps forward by a certain distance
  void warp() {
    if (warpEnergy == warpCooldown) {
      xVel = warpSpeed*(float)Math.sin(angle);
      yVel = warpSpeed*(float)Math.cos(angle);
      xPos += xVel;
      yPos -= yVel;
      warpEnergy = 0;
      checkBoundaries();
    }
  }
  
  //activates the Haste upgrade
  void activateHaste() {
    hasted = true;
    hasteTimer = hasteDuration;
  }

 //moves ship based on received action
  void move(String dir) {
    if (dir.equals("Left")) {
      if (firingBeam) { angle -= 0.35*turnSpeed; }
      else { angle -= turnSpeed; }
    }
    if (dir.equals("Right")) {
      if (firingBeam) { angle += 0.35*turnSpeed; }
      else { angle += turnSpeed; }
    }
    if (dir.equals("Forward")) {
      if (hasted || nitroOn) {
        xVel = nitroSpeed*(float)Math.sin(angle);
        yVel = nitroSpeed*(float)Math.cos(angle);
      } else {
        xVel = moveSpeed*(float)Math.sin(angle);
        yVel = moveSpeed*(float)Math.cos(angle);
      }
      xPos += xVel;
      yPos -= yVel;
      moving = true;
    }
  }
  
  //checks for collisions with bullets
  TurretBullet checkForBulletCollision(List<TurretBullet> bulletList) {
    float collisionSize;
    if (hasted) { collisionSize = size/3; }
    else { collisionSize = size/2; }
    for (TurretBullet b : bulletList) {
      if (b.readyToKill() && Math.sqrt(Math.pow(b.getX()-xPos, 2) + Math.pow(b.getY()-yPos, 2)) < (collisionSize+b.getBulletSize()/2)) {
        alive = false;
        return b;
      }
    }
    return null;
  }
  
  //checks for collisions with missiles
  //checks for a collision with a missile
  Missile checkForMissileCollision(List<Missile> missileList) {
    float collisionSize; //the ship's collision size is smaller while hasted, and so is harder to hit
    if (hasted) { collisionSize = size/3; }
    else { collisionSize = size/2; }
    for (Missile m : missileList) {
      if (Math.sqrt(Math.pow(m.getX()-xPos, 2) + Math.pow(m.getY()-yPos, 2)) < (collisionSize+(m.getCollisionDistance()/2))) {
        alive = false;
        return m;
      }
    }
    return null;
  }
  
  //checks the coordinates stored in boxCoordsX and boxCoordsY (which are the coordinates for the outline of the ship and are not really a box) against the edges of the game window
  void checkBoundaries() {
    float farthestXShift = 0; // we only shift by the farthest displacement between one of the boxCoords coordinates and the edge of the window it is past, so as to not shift the ship multiple times for multiple coordinates that go off-screen
    float farthestYShift = 0;
    float xShift;
    float yShift;
    for (int i = 0; i < boxCoordsX.length; i++) {
      //Left and Right boundaries
      if (boxCoordsX[i] < 0) {
        xShift = 0-boxCoordsX[i];
        if (Math.abs(xShift) > farthestXShift) { farthestXShift = xShift; }
        xVel = 0;
      } else if (boxCoordsX[i] > width) {
        xShift = width-boxCoordsX[i];
        if (Math.abs(xShift) > farthestXShift) { farthestXShift = xShift; }
        xVel = 0;
      }
      //Top and Bottom boundaries
      if (boxCoordsY[i] < 0) {
        yShift = 0-boxCoordsY[i];
        if (Math.abs(yShift) > farthestYShift) { farthestYShift = yShift; }
        yVel = 0;
      } else if (boxCoordsY[i] > height) {
        yShift = height-boxCoordsY[i];
        if (Math.abs(yShift) > farthestYShift) { farthestYShift = yShift; }
        yVel = 0;
      }
    }
    shiftTheShip(farthestXShift, farthestYShift);
  }
  
  //shifts the ship in the x and y direction by the amounts given to this method
  void shiftTheShip(float x, float y) {
    xPos += x;
    yPos += y;
  }
  
  //checks all bullets and missiles for collisions with the shield
  void checkShieldCollision(List<TurretBullet> bulletList, List<Missile> missileList) {
    float distanceFromShipCenter = 0;
    float angleFromShip = 0;
    for (TurretBullet b : bulletList) {
      distanceFromShipCenter = (float)Math.sqrt(Math.pow(xPos-b.getX(), 2) + Math.pow(yPos-b.getY(), 2));
      if (distanceFromShipCenter <= 1.1*shield.getRadius()/2) {
        angleFromShip = atan2(b.getY()-yPos, b.getX()-xPos);
        if (shield.isActive() && !b.alreadyBounced() && distanceFromShipCenter > 0.75*shield.getRadius()/2 && angleFromShip >= shield.getAngle()-shield.getShieldHalfLength() && angleFromShip <= shield.getAngle()+shield.getShieldHalfLength()) {
          //if bullet collided with an active shield
          b.setSpeeds(-b.getXDir()+xVel/2.5, -b.getYDir()-yVel/2.5);
          b.setToBouncedBack();
        }
      }
    }
    for (Missile m : missileList) {
      distanceFromShipCenter = (float)Math.sqrt(Math.pow(xPos-m.getX(), 2) + Math.pow(yPos-m.getY(), 2));
      if (distanceFromShipCenter <= 1.1*shield.getRadius()/2) {
        angleFromShip = atan2(m.getY()-yPos, m.getX()-xPos);
        if (shield.isActive() && !m.alreadyBounced() && distanceFromShipCenter > 0.75*shield.getRadius()/2 && angleFromShip >= shield.getAngle()-shield.getShieldHalfLength() && angleFromShip <= shield.getAngle()+shield.getShieldHalfLength()) {
          m.invertAngle();
          m.setToBouncedBack();
        }
      }
    }
  }
  
  //draws the ship, nitro bar and smoke circles
  void drawShip() {
    //setting velocities back to 0 - this is for the purpose of adding 0 momentum (and therefore speed) to balls that collide with the shield
    xVel = 0;
    yVel = 0;
    
    //drawing the shield
    shield.drawShield(xPos, yPos);
    
    //things to do with the nitro bar, warp bar and haste
    mouseAngle = atan2(mouseY-yPos, mouseX-xPos);
    drawNitroBar();
    doHaste();
    drawWarpBar();
    
    //drawing the ship
    fill(0, 95, 245);
    stroke(0, 40, 190);
    strokeWeight(1);
    
    translate(xPos, yPos);
    rotate(angle);
    
    noStroke();
    rect(-size/2, -size/2, size, size/2);
    triangle(-size/2, -size/2, 0, -1.5*size, size/2, -size/2);
    triangle(-size/2, -size/2, -size/2, 3*size/4, -size/2-size/4, 5*size/4);
    triangle(size/2, -size/2, size/2, 3*size/4, size/2+size/4, 5*size/4);
    
    //drawing the smokes
    drawSmokes();
    
    rotate(-angle);
    translate(-xPos, -yPos);
    
    //updating these arrays for checking boundaries
    for (int i = 0; i < boxCoordsX.length; i++) {
      boxCoordVectors[i] = new PVector(initialBoxCoordsX[i], initialBoxCoordsY[i]);
      boxCoordVectors[i].rotate(angle);
      boxCoordsX[i] = xPos + boxCoordVectors[i].x;
      boxCoordsY[i] = yPos + boxCoordVectors[i].y;
    }
  }
  
  //actions done while the 'haste' status effect is active
  void doHaste() {
    if (hasted) {
      if (hasteTimer <= 0) { 
        hasted = false;
        hasteTimer = 0;
      }
      else { hasteTimer -= 1; }
    }
  }
  
  //drawing the nitro bar
  void drawNitroBar() {
    //nitro properties
    if (nitroOn) {
      nitroDurationTimer -= 1;
      if (nitroDurationTimer < 0) { nitroDurationTimer = 0; }
      if (nitroDurationTimer == 0) {
        nitroOn = false;
      }
    } else {
      nitroDurationTimer += 0.0025*nitroMaxDuration;
      if (nitroDurationTimer > nitroMaxDuration) { nitroDurationTimer = nitroMaxDuration; }
    }
    
    //drawing the nitro bar
    noFill();
    strokeWeight(4);
    if (hasted) { // for when haste is active
      stroke(250, 30, 20);
      arc(xPos, yPos, nitroAndShieldRadius, nitroAndShieldRadius, mouseAngle+(0.75*PI)-nitroBarMaxHalfLength, mouseAngle+(0.75*PI)+nitroBarMaxHalfLength);
      return;
    }
    //for when haste is not active
    if (nitroOn || nitroDurationTimer == nitroMaxDuration) { stroke(10, 225, 225); }
    else { stroke(5, 80, 80); }
    nitroBarLength = nitroBarMaxHalfLength * (nitroDurationTimer/nitroMaxDuration);
    if (nitroDurationTimer > 0) { arc(xPos, yPos, nitroAndShieldRadius, nitroAndShieldRadius, mouseAngle+(0.75*PI)-nitroBarLength, mouseAngle+(0.75*PI)+nitroBarLength); }
  }
  
  //drawing the warp bar
  void drawWarpBar() {
    if (warpEnergy < warpCooldown) { warpEnergy += 0.0025*warpCooldown; }
    if (warpEnergy > warpCooldown) { warpEnergy = warpCooldown; }
    
    //drawing the nitro bar
    noFill();
    strokeWeight(4);
    if (warpEnergy == warpCooldown) { stroke(130, 55, 225); }
    else { stroke(70, 35, 110); }
    
    //drawing the nitro bar
    noFill();
    strokeWeight(4);
    if (warpEnergy == warpCooldown) { stroke(130, 55, 225); }
    else { stroke(70, 35, 110); }
    warpBarLength = warpBarMaxHalfLength * (warpEnergy/warpCooldown);
    if (nitroDurationTimer > 0) { arc(xPos, yPos, nitroAndShieldRadius, nitroAndShieldRadius, mouseAngle+(1.25*PI)-warpBarLength, mouseAngle+(1.25*PI)+warpBarLength); }
  }
  
  //things to do with the smoke clouds
  void drawSmokes() {
    SmokeCircle smoke = new SmokeCircle(-size/2+random(2,size-2), size/4, angle);
    smokeClouds.add(smoke);
    
    if (movingForward) {
      for (SmokeCircle s : smokeClouds) {
        if (s.getShade() <= 0) { smokesToRemove.add(s); }
        else {
          s.drawSmoke();
          s.darkenShade();
        }
      }
      for (SmokeCircle s : smokesToRemove) {
        smokeClouds.remove(s);
      }
      smokesToRemove.clear();
    }
  }
}
