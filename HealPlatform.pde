// Practice3: finish HealPlatform
class HealPlatform extends Platform {
  boolean healed = false;
  float floatOffset = 0;

  float potionW = 20;
  float potionH = 20;

  HealPlatform(float tempX, float tempY) {
    super(tempX, tempY);
  }

  void display() {
    image(platformImage, x, y);

    if (!healed) {
      floatOffset = sin(frameCount * 0.1) * 10 - 5;

      float potionX = x + (w - potionW) / 2;
      float potionY = y - potionH + floatOffset;

      image(healPotionImage, potionX, potionY, potionW, potionH);
    }
  }

  void interact(Player player) {
    if (!healed && player.isOnPlatform(this)) {
      player.health = min(player.health + 1, PLAYER_HEALTH);
      healed = true;
      playPlatformSound();
    }
    super.interact(player);
  }

  void playPlatformSound() {
    if (!playedSound) {
      healSound.play();
      playedSound = true;
    }
  }
}
