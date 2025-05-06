class Platform {
  float x, y, w = 80, h = 20, speed = 2; // Position, size, and speed of the platform
  boolean recycleFlag = false; // Flag to indicate if the platform needs recycling
  boolean playedSound = false; // Flag to indicate if the sound has been played

  Platform(float tempX, float tempY) {
    x = tempX;
    y = tempY;
  }

  void update() {
    y -= speed; // Move the platform up
    if (y < -h) {
      recycleFlag = true; // Mark the platform for recycling
    }
  }

  void interact(Player player) {
    player.ySpeed = 0; // Reset the player's ySpeed
    player.y = y - player.h + player.feetOffset; // Place the player on top of the platform
    player.y -= speed; // Move the player up with the platform
    
    // Practice4: Avoid sound being repeatedly played

  }

  void display() {
    image(platformImage, x, y, w, h); // Draw the platform
  }

}
