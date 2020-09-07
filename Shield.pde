class Shield {
  //position and direction of the shield
  float xPos, yPos;
  float angle;
  //properties of the shield
  float maxShieldEnergy;
  float shieldEnergy;
  float radius;
  float shieldMaxHalfLength;
  float shieldHalfLength;
  float chargingCooldown;
  float chargeCDTimer;
  boolean active;
  
  Shield(float x, float y, float rad, float fR) {
    xPos = x;
    yPos = y;
    angle = 0;
    
    maxShieldEnergy = 200;
    shieldEnergy = maxShieldEnergy;
    radius = rad;
    shieldMaxHalfLength = 1.1*QUARTER_PI;
    shieldHalfLength = shieldMaxHalfLength;
    chargingCooldown = 1.0*fR;
    chargeCDTimer = 0;
    active = false;
  }
  
  //getters
  float getRadius() { return radius; }
  float getAngle() { return angle; }
  float getShieldHalfLength() { return shieldHalfLength; }
  boolean isActive() { return active; }
  
  //setters
  void reset() { shieldEnergy = maxShieldEnergy; }
  
  //sets its state to the given state name: either "On" or "Off"
  void setState(String state) {
    if (state.equals("On") && shieldEnergy > 0) {
      active = true;
      chargeCDTimer = chargingCooldown;
    } else if (shieldEnergy == 0 || state.equals("Off")) {
      active = false;
    }
  }
  
  //draws the shield, and changes shieldHalfLength and shieldEnergy
  void drawShield(float shipX, float shipY) {
    if (active && shieldEnergy > 0) { stroke(250); }
    else { stroke(95); }
    strokeWeight(4);
    noFill();
    
    //making the shield length the same proportion of its maximum length as the proportion between the current shieldEnergy amount and the maximum shieldEnergy value
    shieldHalfLength = shieldMaxHalfLength * (shieldEnergy/maxShieldEnergy);
    angle = atan2(mouseY-shipY, mouseX-shipX);
    arc(shipX, shipY, radius, radius, angle-shieldHalfLength, angle+shieldHalfLength);
    
    if (active) {
      shieldEnergy -= 2;
      if (shieldEnergy < 0) { shieldEnergy = 0; }
    } else {
      if (chargeCDTimer > 0) {
        chargeCDTimer -= 1;
      } else {
        shieldEnergy += 0.5;
        if (shieldEnergy > maxShieldEnergy) { shieldEnergy = maxShieldEnergy; }
        if (chargeCDTimer < 0) { chargeCDTimer = 0; }
      }
    }
  }
}
