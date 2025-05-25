// Practice1: finish SpikyPlatform
class SpikyPlatform extends Platform {
  boolean hasDamaged = false;

  SpikyPlatform(float tempX, float tempY) {
    super(tempX, tempY);
  }

  void display() {
    image(spikyPlatformImage, x, y);
  }

  void interact(Player player) {
    if (!hasDamaged && player.isOnPlatform(this)) {
      player.takeDamage(1);
      hasDamaged = true;
      playPlatformSound();
    }
    super.interact(player);
  }

  void playPlatformSound() {
    if (!playedSound) {
      spikyPlatformSound.play();
      playedSound = true;
    }
  }
}
