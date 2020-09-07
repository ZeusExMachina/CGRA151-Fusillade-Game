class PlusTenScore {
  float xPos, yPos;
  float shade;
  
  PlusTenScore(float x, float y) {
    xPos = x;
    yPos = y;
    shade = 0;
  }
  
  //getters
  float getShade() { return shade; }
  
  //setters
  void resetShade() { shade = 255; }
  
  void displayPlusTen(float shipX, float shipY) {
    textSize(25);
    fill(shade);
    textAlign(CENTER);
    xPos = shipX;
    yPos = shipY;
    text("+10", xPos, yPos+10);
    shade -= 2.5;
  }
}
