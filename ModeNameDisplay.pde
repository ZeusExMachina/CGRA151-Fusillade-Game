class ModeNameDisplay {
  float xPos, yPos;
  float shade;
  
  ModeNameDisplay() {
    xPos = width/2;
    yPos = height/6;
    shade = 255;
  }
  
  //getters
  float getShade() { return shade; }
  
  //setters
  void resetShade() { shade = 255; }
  
  //displays the mode name text
  void displayModeName(boolean hardMode) {
    fill(shade);
    textAlign(CENTER);
    textSize(60);
    if (hardMode) {
      text("Hard Mode", xPos, yPos);
      textSize(30);
      text("Careful!", xPos, 3*yPos);
      text("Turrets Spawn more Often", xPos, 3.5*yPos);
      text("Missiles and Bullets move faster", xPos, 4*yPos);
      text("Bullets bounce off of Walls", xPos, 4.5*yPos);
    }
    else {
      text("Normal Mode", xPos, yPos);
      textSize(30);
      text("Use W, A, and D to move", xPos, 3*yPos);
      text("E to activate Nitro Boost", xPos, 3.5*yPos);
      text("Left Mouse Button to use the Shield", xPos, 4*yPos);
      text("Space Bar to Warp in the distance faced", xPos, 4.5*yPos);
    }
    shade -= 1;
  }
}
