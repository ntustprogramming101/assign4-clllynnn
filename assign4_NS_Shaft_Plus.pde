import processing.sound.*;

// Constants
final int NUM_PLATFORMS = 10;
final int PLAYER_HEALTH = 3;
final float SCROLL_SPEED = -2;
final int PLAYER_FEET_OFFSET = 5; // Offset distance between the player's feet and the platform
final int INVINCIBILITY_DURATION = 180; // 3 seconds at 60 FPS
final int DAMAGE_BLINK_DURATION = 30;
final int ANIMATION_INTERVAL = 10;
final int FRAME_RATE = 60; // Frames per second
final int WIN_MINIMUM_TIME = 10; // Time in seconds required to win
final float SLIDE_SPEED = 5; // Speed at which the win image slides in
final int GAME_RUN = 0, GAME_WIN = 1, GAME_OVER = 2; // Game states
// Game Variables
Platform[] platforms = new Platform[NUM_PLATFORMS]; // Array to store all platforms
Player player; // The player object
PImage[][] playerSprites = new PImage[3][]; // Array to store player sprites
// 1st[]: sprite index (0=idle, 1=left, 2=right) ; 2nd[]: animated frame index
float bgY1 = 0, bgY2; // Vertical positions of the two background images for scrolling
PImage bg; // Background image
PImage platformImage; // Images for platforms
PImage bouncyPlatformImage; // Image for bouncy platforms
PImage fragilePlatformImage; // Image for fragile platforms
PImage fragilePlatformBrokenImage; // Image for broken fragile platforms
PImage spikyPlatformImage; // Image for spiky platforms
PImage healPotionImage; // Image for healing potions
PImage winImage; // The image displayed when the player wins
float winImageY; // The vertical position of the win image
float winImageHeight; // The height of the win image
int survivalTime = 0; // Time the player has survived in seconds
int frameCounter = 0; // Counter to track frames for timing purposes
int gameState; // Current game state
SoundFile platformSound; // Sound for platform interaction
SoundFile bouncyPlatformSound; // Sound for bouncy platform interaction
SoundFile fragilePlatformSound; // Sound for fragile platform interaction
SoundFile fragilePlatformBrokenSound; // Sound for broken fragile platform interaction
SoundFile spikyPlatformSound; // Sound for spiky platform interaction
SoundFile healSound; // Sound for healing

// Setup
void setup() {
  size(400, 600);
  frameRate(FRAME_RATE); // Set the frame rate
  loadAssets();
  initializeGame();
}

void loadAssets() {
  bg = loadImage("background.png");
  bg.resize(width, height); // Resize the background image to fit the screen
  bgY2 = -height; // Second background image starts off-screen
  platformImage = loadImage("cloud.png");
  bouncyPlatformImage = loadImage("bouncy_platform.png");
  fragilePlatformImage = loadImage("fragile_platform.png");
  fragilePlatformBrokenImage = loadImage("fragile_platform_broken.png");
  spikyPlatformImage = loadImage("spiky_platform.png");
  healPotionImage = loadImage("healing_potion.png");
  winImage = loadImage("win_image.png"); // Load the win image
  winImage.resize(width, 0); // Resize the win image to fit the screen
  winImageHeight = winImage.height; // Get the height of the win image
  winImageY = height; // set the win image off-screen

  // Initialize the playerSprites array with subarrays for different movement states
  playerSprites[0] = new PImage[1]; // idle state (1 frame)
  playerSprites[1] = new PImage[2]; // moving left (2 frames for animation)
  playerSprites[2] = new PImage[2]; // moving right (2 frames for animation)

  // Load the sprite images for each movement state
  playerSprites[0][0] = loadImage("idle.png"); // Idle sprite
  playerSprites[1][0] = loadImage("move_left1.png"); // First frame of moving left
  playerSprites[1][1] = loadImage("move_left2.png"); // Second frame of moving left
  playerSprites[2][0] = loadImage("move_right1.png"); // First frame of moving right
  playerSprites[2][1] = loadImage("move_right2.png"); // Second frame of moving right

  // Load sound files
  platformSound = new SoundFile(this, "normal.mp3");
  bouncyPlatformSound = new SoundFile(this, "bouncy.mp3");
  fragilePlatformSound = new SoundFile(this, "fragile.mp3");
  fragilePlatformBrokenSound = new SoundFile(this, "fragile_broken.mp3");
  spikyPlatformSound = new SoundFile(this, "spiky.mp3");
  healSound = new SoundFile(this, "heal.mp3");
}

void initializeGame() {
  player = new Player();
  initializePlatforms();
  survivalTime = 0;
  frameCounter = 0;
  gameState = GAME_RUN; // Set the initial game state to running
  winImageY = height; // Start the win image off-screen
}

void initializePlatforms() {
  // stage 1-1: generate 10 platforms with random positions on the screen
  for (int i = 0; i < NUM_PLATFORMS; i++) {
    // you need to change this line to create a new platform object with random horizontal positions, while distributed evenly in vertical space
    platforms[i] = assignRandomPlatform(random(width), i * (height / NUM_PLATFORMS));
  }
  // End of stage 1-1
}

// Main Game Loop
void draw() {
  scrollBackground(); // Scroll the background continuously

  switch (gameState){
    case GAME_RUN:
      runGame();
      break;
    case GAME_WIN:
      winGame();
      break;
    case GAME_OVER:
      endGame();
      break;
  }
}

void runGame(){
  for (int i = 0; i < platforms.length; i++) {
    platforms[i].update(); // Update the platform's position
    // Handle recycling
    if (platforms[i].recycleFlag) {
      platforms[i] = assignRandomPlatform(random(width), height); // Replace with a new random platform
    }
    platforms[i].display(); // Display the platform on the screen
  }

  player.update(); // Update the player's position and state
  player.display(); // Display the player on the screen

  frameCounter++;
  if (frameCounter % FRAME_RATE == 0) {
    survivalTime++; // Increment survival time every second
  }
  displayHealthAndTimer(); // Display the player's health and survival time

  if (player.health <= 0) { // check if gameover (player is dead)
    gameState = GAME_OVER;  // Set the game state to game over
  }

  if (survivalTime >= WIN_MINIMUM_TIME) { // Check if the player has survived long enough to win
    gameState = GAME_WIN; // Set the game state to win
  }
}

// Assign a random platform type
Platform assignRandomPlatform(float x, float y) {
  int typeIndex = int(random(5)); // Randomly select a type (0 = normal, 1 = bouncy, 2 = spiky, 3 = fragile, 4 = healing)
  switch (typeIndex) {
    case 0:
      return new Platform(x, y); // Normal platform
    case 1:
      return new BouncyPlatform(x, y); // Bouncy platform
    case 2:
      return new SpikyPlatform(x, y); // Spiky platform
    case 3:
      return new FragilePlatform(x, y); // Fragile platform
    case 4:
      return new HealPlatform(x, y); // Healing platform
    default :
      return new Platform(x, y); // Fallback to normal platform
  }
  
}

// Background Scrolling
void scrollBackground() {
  image(bg, 0, bgY1); // Draw the first background image
  image(bg, 0, bgY2); // Draw the second background image

  bgY1 += SCROLL_SPEED; // Move the first background image up
  bgY2 += SCROLL_SPEED; // Move the second background image up

  // Reset the background positions when they scroll out of view
  if (bgY1 <= -bg.height) bgY1 = bgY2 + bg.height;
  if (bgY2 <= -bg.height) bgY2 = bgY1 + bg.height;
}

// Display Functions
void displayHealthAndTimer() {
  fill(0);
  textSize(16);
  textAlign(LEFT, TOP);
  text("Health: " + player.health, 10, 20); // Display health
  text("Time: " + survivalTime + " s", 10, 40); // Display survival time
}

// Handles the win condition
void winGame() {
  displayWinImage(); // Show the win image
  player.forceDropToBottom(); // Allow the player to drop to the bottom of the screen
  if (player.y < height - winImageHeight / 2) {
    player.display(); // Display the player on the screen
  }
  displayWinMessage(); // Show a congratulatory message 
}
// Handles the end of the game
void endGame() {
  player.forceDropToBottom(); // Allow the player to drop to the bottom of the screen
  player.display(); // Display the player on the screen
  displayGameOver(); // Show a game-over message if the player has lost
}

// Win Image Functions
void displayWinImage() {
  if (winImageY > height - winImageHeight) {
    winImageY -= SLIDE_SPEED;
  } else {
    winImageY = height - winImageHeight; // Stop at the bottom of the screen
  }
  image(winImage, 0, winImageY, width, winImageHeight); // Displays the win image at its current position
}

// Displays a game-over message when the player loses
void displayGameOver() {
  textAlign(CENTER, CENTER);
  textSize(32);
  fill(255, 0, 0);
  text("Game Over", width / 2, height / 2 - 20);

  textSize(16);
  fill(0);
  text("You survived: " + survivalTime + " seconds", width / 2, height / 2 + 20);
  text("Press R to restart", width / 2, height / 2 + 40);
}

// Displays a congratulatory message when the player wins
void displayWinMessage() {
  textAlign(CENTER, CENTER);
  textSize(32);
  fill(0, 255, 0);
  text("Congratulations!", width / 2, height / 2 - 20);

  textSize(16);
  fill(0);
  text("You survived: " + survivalTime + " seconds", width / 2, height / 2 + 20);
  text("Press R to restart", width / 2, height / 2 + 40);
}

// Input Handling
void keyPressed() {
  if (key == 'a' || key == 'A') {
    player.setMovement(-1);
  } else if (key == 'd' || key == 'D') {
    player.setMovement(1);
  } else if (key == 'r' || key == 'R') {
    restartGame();
  }
}

void keyReleased() {
  if (key == 'a' || key == 'A' || key == 'd' || key == 'D') {
    player.setMovement(0); // Stop moving
  }
}

void restartGame() {
  initializeGame();
}
