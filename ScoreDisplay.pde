class ScoreDisplay {
  float xPos, yPos;
  int score;
  float shade;
  
  ScoreDisplay() {
    xPos = width/55;
    yPos = height/20;
    score = 0;
    shade = 255;
  }
  
  int getScore() { return score; }
  void addTen() { score += 10; }
  void reset() { score = 0; }
  
  void displayScore(boolean gameRunning, int backgroundRed, int backgroundGreen, int backgroundBlue) {
    if (gameRunning) { fill(shade); }
    else { fill(backgroundRed, backgroundGreen, backgroundBlue); }
    textSize(35);
    textAlign(LEFT);
    text("Score: "+ Integer.toString(score), xPos, yPos);
  }
}
