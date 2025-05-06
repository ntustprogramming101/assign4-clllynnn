class BouncyPlatform extends Platform {
  float bounciness = 10; // Bounce strength

  BouncyPlatform(float tempX, float tempY) {
    super(tempX, tempY);
  }

  void interact(Player player) {
    player.ySpeed = -bounciness; // Bounce the player upwards
    player.y = y - player.h + player.feetOffset; // Place the player on top of the platform
    player.y -= speed; // Move the player up with the platform
    playPlatformSound(); // Play the platform sound
  }

  void display() {
    // Use a different image for bouncy platforms
    image(bouncyPlatformImage, x, y, w, h);
  }

  void playPlatformSound() {
    bouncyPlatformSound.play(); // Play the bouncy platform sound
  }
}
