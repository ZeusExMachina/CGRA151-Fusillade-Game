import java.util.*;

//Variables for core game functions
int time = 0;
int timer = 0;
int framerate = 60;
int backgroundRed = 0;
int backgroundGreen = 0;
int backgroundBlue = 0;
boolean hardModeOn = false;
boolean gameRunning = true;

//Variables to do with the ship
Ship ship;
boolean turningCC = false;
boolean turningClock = false;
boolean movingForward = false;
boolean usingNitro = false;

//Turret and Projectile Initial Spawning Chances (normal mode). For hard mode spawn chances, check the restartInHard() method
float turretSpawnChance = 0.45;
float missileTurretSpawnChance = 0.1;
float bulletSpawnChance = 0.4;
float missileSpawnChance = 0.15;
float missileNumLimit = 3;
float upgradeDropChance = 0.075;

//Variables for upgrade objects
FreezeField freeze;
ViolentTwister twister;
Haste haste;
HyperBeam beam;

//Variables for other objects
List<Turret> turrets, turretsToRemove;
List<MissileTurret> missileTurrets, missileTurretsToRemove;
List<TurretBullet> bullets, bulletsToRemove;
List<Missile> missiles, missilesToRemove;
ModeNameDisplay modeName;
ScoreDisplay score;
PlusTenScore plusTen;

void setup() {
  size(1200, 900);
  frameRate(framerate);

  ship = new Ship(framerate);
  freeze = new FreezeField(framerate);
  twister = new ViolentTwister(framerate);
  haste = new Haste(framerate);
  beam = new HyperBeam(framerate);
  
  turrets = new ArrayList<Turret>();
  turretsToRemove = new ArrayList<Turret>();
  missileTurrets = new ArrayList<MissileTurret>();
  missileTurretsToRemove = new ArrayList<MissileTurret>();
  bullets = new ArrayList<TurretBullet>();
  bulletsToRemove = new ArrayList<TurretBullet>();
  missiles = new ArrayList<Missile>();
  missilesToRemove = new ArrayList<Missile>();

  modeName = new ModeNameDisplay();
  score = new ScoreDisplay();
  plusTen = new PlusTenScore(ship.getX(), ship.getY());
}

void draw() {
  if (!gameRunning) { // checking to see if the ship is dead to end the game or not
    score.displayScore(gameRunning, backgroundRed, backgroundGreen, backgroundBlue);
    fill(255);
    textAlign(CENTER);
    textSize(60);
    text("GAME OVER", width/2, height/6);
    textSize(45);
    text("Score: "+score.getScore(), width/2, height/3);
    textSize(25);
    text("Press 'g' to restart in this mode, or 'h' to switch modes", width/2, height/2);
    return;
  }

  //background colour
  if (hardModeOn) {
    backgroundRed = 45;
    backgroundGreen = 0;
    backgroundBlue = 10;
  } 
  else { 
    backgroundRed = 0;
    backgroundGreen = 0;
    backgroundBlue = 0;
  }
  background(backgroundRed, backgroundGreen, backgroundBlue);

  //player ship movement
  if (turningCC) { ship.move("Left"); }
  if (turningClock) { ship.move("Right"); }
  if (movingForward) { ship.move("Forward"); }

  //drawing ship and upgrades
  doViolentTwister();
  doHyperBeam();
  doHaste();
  doShip();
  doFreezingField();

  //drawing and deleting turrets and projectiles
  doBulletStuff();
  doMissileStuff();
  doTurrets();
  doMissileTurrets();

  //spawn stuff once a second
  if (timer == framerate) {
    spawnTurretsAndProjectiles();
    dropUpgrades();
  }

  //drawing the Plus Ten, if a turret was destroyed recently, as well as the total score;
  if (plusTen.getShade() > 0) { 
    plusTen.displayPlusTen(ship.getX(), ship.getY());
  }
  score.displayScore(gameRunning, backgroundRed, backgroundGreen, backgroundBlue);

  //displaying mode name
  if (modeName.getShade() > 0) {
    modeName.displayModeName(hardModeOn);
  }

  //incrementing timer
  timer++;
  gameRunning = ship.isAlive();
}

//drawing the ship
void doShip() {
  ship.checkShieldCollision(bullets, missiles);
  ship.checkForBulletCollision(bullets);
  ship.checkForMissileCollision(missiles);
  ship.checkBoundaries();
  ship.drawShip();
}

//drawing upgrades
void doHaste() { // Haste
  haste.checkForShipCollision(ship.getX(), ship.getY(), ship.getSize(), ship);
  if (haste.isDropped()) { haste.drawIcon(); }
  else if (haste.textShowing()) { haste.drawText(); }
}
void doFreezingField() { // Freezing Field
  //Freezing Field
  freeze.checkForShipCollision(ship.getX(), ship.getY(), ship.getSize());
  if (freeze.isDropped()) { freeze.drawIcon(); }
  else if (freeze.isActive()) { 
    freeze.drawFreezeField();
    for (Turret t : turrets) {
      if (Math.abs(freeze.getRadius()-Math.sqrt(Math.pow(t.getX()-freeze.getX(), 2) + Math.pow(t.getY()-freeze.getY(), 2))) < freeze.getTurretCollThreshold()) { t.freeze(); }
    }
    for (MissileTurret t : missileTurrets) {
      if (!t.isFrozen() && Math.abs(freeze.getRadius()-Math.sqrt(Math.pow(t.getX()-freeze.getX(), 2) + Math.pow(t.getY()-freeze.getY(), 2))) < freeze.getTurretCollThreshold()) { t.freeze(); }
    }
  }
}
void doHyperBeam() { // Hyper Beam
  beam.checkForShipCollision(ship.getX(), ship.getY(), ship.getSize());
  if (beam.isDropped()) { beam.drawIcon(); }
  else if (beam.isActive()) {
    beam.drawBeam(ship.getX(), ship.getY(), ship.getSize(), ship.getAngle(), ship);
    PVector posVectorFromShip; //a position vector of each object that is relative to the ship
    if (beam.isCharging()) { return; } //if the beam is charging, don't do anything else
    for (Turret t : turrets) { //turrets
      posVectorFromShip = new PVector(t.getX()-ship.getX(), t.getY()-ship.getY());
      posVectorFromShip.rotate(-beam.getBeamAngle());
      if (posVectorFromShip.x >= beam.getX() && posVectorFromShip.x <= beam.getX()+beam.getBeamWidth() && posVectorFromShip.y >= beam.getY() && posVectorFromShip.y <= beam.getY()+beam.getBeamHeight()) {
        turretsToRemove.add(t);
        plusTen.resetShade();
      }
    }
    for (MissileTurret t : missileTurrets) { //missile turrets
      posVectorFromShip = new PVector(t.getX()-ship.getX(), t.getY()-ship.getY());
      posVectorFromShip.rotate(-beam.getBeamAngle());
      if (posVectorFromShip.x >= beam.getX() && posVectorFromShip.x <= beam.getX()+beam.getBeamWidth() && posVectorFromShip.y >= beam.getY() && posVectorFromShip.y <= beam.getY()+beam.getBeamHeight()) {
        missileTurretsToRemove.add(t);
        plusTen.resetShade();
      }
    }
    for (TurretBullet t : bullets) { //bullets
      posVectorFromShip = new PVector(t.getX()-ship.getX(), t.getY()-ship.getY());
      posVectorFromShip.rotate(-beam.getBeamAngle());
      if (posVectorFromShip.x >= beam.getX() && posVectorFromShip.x <= beam.getX()+beam.getBeamWidth() && posVectorFromShip.y >= beam.getY() && posVectorFromShip.y <= beam.getY()+beam.getBeamHeight()) {
        bulletsToRemove.add(t);
        plusTen.resetShade();
      }
    }
    for (Missile t : missiles) { //missiles
      posVectorFromShip = new PVector(t.getX()-ship.getX(), t.getY()-ship.getY());
      posVectorFromShip.rotate(-beam.getBeamAngle());
      if (posVectorFromShip.x >= beam.getX() && posVectorFromShip.x <= beam.getX()+beam.getBeamWidth() && posVectorFromShip.y >= beam.getY() && posVectorFromShip.y <= beam.getY()+beam.getBeamHeight()) {
        missilesToRemove.add(t);
        plusTen.resetShade();
      }
    }
  }
}
void doViolentTwister() { // Violent Twister
  twister.checkForShipCollision(ship.getX(), ship.getY(), ship.getSize());
  if (twister.isDropped()) { twister.drawIcon(); }
  else if (twister.isActive()) { 
    twister.drawTwister();
    float dist;
    float ang;
    //ship
    dist = (float)Math.sqrt(Math.pow(ship.getX()-twister.getX(), 2) + Math.pow(ship.getY()-twister.getY(), 2));
    ang = atan2(ship.getY()-twister.getY(), ship.getX()-twister.getX());
    if (dist < twister.getSingularityRadius()) { ship.spinInSingularity(twister.getX(), twister.getY()); }
    else { ship.shiftTheShip(-0.6*twister.getGravitationalInfluence()*(float)Math.cos(ang)*(1/(dist)), -0.6*twister.getGravitationalInfluence()*(float)Math.sin(ang)*(1/(dist))); }
    for (Turret t : turrets) { //turrets
      dist = (float)Math.sqrt(Math.pow(t.getX()-twister.getX(), 2) + Math.pow(t.getY()-twister.getY(), 2));
      if (dist <= twister.getSingularityRadius()) { 
        turretsToRemove.add(t);
        plusTen.resetShade();
      }
      else { 
        ang = atan2(t.getY()-twister.getY(), t.getX()-twister.getX());
        t.shiftTurret(-twister.getGravitationalInfluence()*(float)Math.cos(ang)*(1/dist), -twister.getGravitationalInfluence()*(float)Math.sin(ang)*(1/dist));
      }
    }
    for (MissileTurret t : missileTurrets) { //missile turrets
      dist = (float)Math.sqrt(Math.pow(t.getX()-twister.getX(), 2) + Math.pow(t.getY()-twister.getY(), 2));
      if (dist <= twister.getSingularityRadius()) {
        missileTurretsToRemove.add(t);
        plusTen.resetShade();
      }
      else { 
        ang = atan2(t.getY()-twister.getY(), t.getX()-twister.getX());
        t.shiftTurret(-twister.getGravitationalInfluence()*(float)Math.cos(ang)*(1/dist), -twister.getGravitationalInfluence()*(float)Math.sin(ang)*(1/dist));
        plusTen.resetShade();
      }
    }
    for (TurretBullet t : bullets) { //bullets
      dist = (float)Math.sqrt(Math.pow(t.getX()-twister.getX(), 2) + Math.pow(t.getY()-twister.getY(), 2));
      if (dist <= twister.getSingularityRadius()) { bulletsToRemove.add(t); }
      else { 
        ang = atan2(t.getY()-twister.getY(), t.getX()-twister.getX());
        t.shift(-twister.getGravitationalInfluence()*(float)Math.cos(ang)*(1/dist), -twister.getGravitationalInfluence()*(float)Math.sin(ang)*(1/dist));
      }
    }
    for (Missile t : missiles) { //missiles
      dist = (float)Math.sqrt(Math.pow(t.getX()-twister.getX(), 2) + Math.pow(t.getY()-twister.getY(), 2));
      if (dist <= twister.getSingularityRadius()) { missilesToRemove.add(t); }
      else { 
        ang = atan2(t.getY()-twister.getY(), t.getX()-twister.getX());
        t.shift(-twister.getGravitationalInfluence()*(float)Math.cos(ang)*(1/dist), -twister.getGravitationalInfluence()*(float)Math.sin(ang)*(1/dist));
      }
    }
  }
}

//potentially dropping upgrades
void dropUpgrades() {
  float upgradeDropper = random(0, 1);
  if (upgradeDropper < upgradeDropChance) {
    int upgradeType = (int)random(0, 4);
    if (!freeze.isDropped() && !freeze.isActive() && upgradeType==0) { freeze.drop(random(25, width-25), random(25, height-25)); }
    if (!twister.isDropped() && !twister.isActive() && upgradeType==1) { twister.drop(random(50, width-50), random(50, height-50)); }
    if (!haste.isDropped() && !ship.isHasted() && upgradeType==2) { haste.drop(random(25, width-25), random(25, height-25)); }
    if (!beam.isDropped() && !beam.isActive() && upgradeType==3) { beam.drop(random(25, width-25), random(25, height-25)); }
  }
}

//draws and removes bullet turrets
void doTurrets() {
  for (Turret t : turrets) {
    TurretBullet b = t.checkForBulletCollision(bullets);
    Missile m = t.checkForMissileCollision(missiles);
    if (t.isDead()) {
      turretsToRemove.add(t);
      if (b != null) { bulletsToRemove.add(b); }
      if (m != null) { missilesToRemove.add(m); }
      plusTen.resetShade();
    }
    t.doMove(turrets, missileTurrets, ship.getX(), ship.getY());
    t.drawTurret(ship.getX(), ship.getY());
  }
  for (Turret t : turretsToRemove) {
    turrets.remove(t);
    t = null;
    score.addTen();
  }
  turretsToRemove.clear();
}

//draws and removes missile turrets
void doMissileTurrets() {
  for (MissileTurret t : missileTurrets) {
    TurretBullet b = t.checkForBulletCollision(bullets);
    Missile m = t.checkForMissileCollision(missiles);
    if (t.isDead()) {
      missileTurretsToRemove.add(t);
      if (b != null) { bulletsToRemove.add(b); }
      if (m != null) { missilesToRemove.add(m); }
      plusTen.resetShade();
    }
    t.doMove(turrets, missileTurrets, ship.getX(), ship.getY());
    t.drawTurret(ship.getX(), ship.getY());
  }
  for (MissileTurret t : missileTurretsToRemove) {
    missileTurrets.remove(t);
    t = null;
    score.addTen();
  }
  missileTurretsToRemove.clear();
}

//draws and removes bullets
void doBulletStuff() {
  for (TurretBullet b : bullets) {
    b.drawBullet(hardModeOn);
    if (hardModeOn) { //for hard mode
      if (b.isPastTravelLimit()) { 
        bulletsToRemove.add(b);
      } else if (b.isPastBoundary()) { 
        b.deflectOffBoundary();
      }
    } else { //for normal mode
      if (b.isPastBoundary()) { 
        bulletsToRemove.add(b);
      }
    }
  }
  for (TurretBullet b : bulletsToRemove) { //removing bullets
    bullets.remove(b);
    b = null;
  }
  bulletsToRemove.clear();
}

//draws and removes missiles
void doMissileStuff() {
  for (Missile m : missiles) {
    m.drawMissile(ship.getX(), ship.getY(), hardModeOn);
    if (m.isPastBoundary()) { 
      missilesToRemove.add(m);
    }
  }
  for (Missile m : missilesToRemove) { //removing missiles
    missiles.remove(m);
    m = null;
  }
  missilesToRemove.clear();
}

//code for spawning turrets, bullets, and missiles
void spawnTurretsAndProjectiles() {
  //spawning new turrets and missile turrets
  float enemySpawner = random(0, 1);
  if (enemySpawner < missileTurretSpawnChance) {
    MissileTurret mTurret = new MissileTurret(framerate);
    missileTurrets.add(mTurret);
    mTurret.drawTurret(ship.getX(), ship.getY());
  } else if (enemySpawner < turretSpawnChance) {
    Turret turret = new Turret(framerate);
    turrets.add(turret);
    turret.drawTurret(ship.getX(), ship.getY());
  }

  //shooting/spawning bullets and missiles
  for (Turret t : turrets) {
    if (!t.isFrozen()) {
      float bulletSpawner = random(0, 1);
      if (bulletSpawner < bulletSpawnChance) {
        fill(0, 0, 255);
        TurretBullet bullet = new TurretBullet(t.getX(), t.getY(), t.getDistanceForSafeBullet());
        bullet.setSpeeds(cos(t.getAngle()), sin(t.getAngle()));
        bullets.add(bullet);
      }
    }
  }
  for (MissileTurret t : missileTurrets) {
    if (!t.isFrozen()) {
      float missileSpawner = random(0, 1);
      if (missiles.size() < missileNumLimit && missileSpawner < missileSpawnChance) {
        fill(0, 0, 255);
        Missile missile = new Missile(t.getX(), t.getY(), t.getAngle(), t.getDistanceForSafeBullet());
        missiles.add(missile);
      }
    }
  }
  timer = 0;
  //incrementing time
  time++;
  if (!ship.isAlive()) { 
    gameRunning = false;
  }
}

//resets variables
void initiateReset() {
  turrets.clear();
  missileTurrets.clear();
  bullets.clear();
  missiles.clear();
  
  ship = new Ship(framerate);
  freeze = new FreezeField(framerate);
  twister = new ViolentTwister(framerate);
  haste = new Haste(framerate);
  beam = new HyperBeam(framerate);

  modeName.resetShade();
  score.reset();
  gameRunning = true;
}

//setting variables appropriately for restarting in normal mode
void restartInNormal() {
  hardModeOn = false;
  turretSpawnChance = 0.45;
  missileTurretSpawnChance = 0.2;
  bulletSpawnChance = 0.4;
  missileSpawnChance = 0.1;
  missileNumLimit = 3;
}

//setting variables appropriately for restarting in hard mode
void restartInHard() {
  hardModeOn = true;
  turretSpawnChance = 0.54;
  missileTurretSpawnChance = 0.3;
  bulletSpawnChance = 0.35;
  missileSpawnChance = 0.15;
  missileNumLimit = 4;
}

void mousePressed() {
  ship.getShield().setState("On");
}

void mouseReleased() {
  ship.getShield().setState("Off");
}

void keyPressed() {
  //ship movement things
  if (key == 'w'|| key == 'W') { 
    movingForward = true;
  }
  if (key == 'a' || key == 'A') { 
    turningCC = true;
  }
  if (key == 'd' || key == 'D') { 
    turningClock = true;
  }
  if (key == 'e' || key == 'E') { 
    ship.activateNitro();
  }
  if (key == ' ') {
    ship.warp();
  }

  //reset buttons
  if (key == 'h' || key == 'H') {
    if (hardModeOn) { 
      restartInNormal();
    } else { 
      restartInHard();
    }
    initiateReset();
  }
  if (key == 'g' || key == 'G') {
    if (hardModeOn) { 
      restartInHard();
    } else { 
      restartInNormal();
    }
    initiateReset();
  }
}

void keyReleased() {
  //ship movement things
  if (key == 'w' || key == 'W') {
    movingForward = false;
  }
  if (key == 'a' || key == 'A') { 
    turningCC = false;
  }
  if (key == 'd' || key == 'D') { 
    turningClock = false;
  }
}
