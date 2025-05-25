// Practice2: finish FragilePlatform
final int FRAGILE_PLATFORM_DURATION = 50; // Duration before the platform breaks

class FragilePlatform extends Platform {
  boolean isBroken = false;
  boolean activated = false;
  boolean playedSound = false;
  int appearFrame;

  FragilePlatform(float tempX, float tempY) {
    super(tempX, tempY);
    appearFrame = frameCount;
  }

  void update() {
    super.update();
    if (activated && !isBroken && frameCount - appearFrame >= FRAGILE_PLATFORM_DURATION) {
      isBroken = true;
      playPlatformSound();
    }
  }

  void display() {
    if (isBroken) {
      image(fragilePlatformBrokenImage, x, y);
    } else {
      image(fragilePlatformImage, x, y);
    }
  }

  void interact(Player player) {
    if (!isBroken && player.isOnPlatform(this)) {
      if (!activated) {
        activated = true;
        appearFrame = frameCount;
        playPlatformSound();
      }
      super.interact(player);
    }
  }

  void playPlatformSound() {
    if (!playedSound) {
      if (isBroken) {
        fragilePlatformBrokenSound.play();
      } else {
        fragilePlatformSound.play();
      }
      playedSound = true;
    }
  }
}
