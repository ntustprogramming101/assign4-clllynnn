// Player Class: Represents the player in the game
class Player {
  float x, y, w = 30, h = 60, xSpeed = 5, ySpeed = 0, gravity = 0.4; // Position, size, speed, and physics
  int health = PLAYER_HEALTH; // Player's health
  int moveDir = 0; // Movement direction, 0=idle, 1=right, -1=left
  int spriteIndex = 0; // sprite index: 0=idle, 1=left, 2=right
  int animatedFrameIndex = 0; // animated frame index for the sprite
  boolean invincible = true, damaged = false; // Flags for invincibility and damage states
  int invincibilityTimer = INVINCIBILITY_DURATION, damageTimer = 0; // Timers for invincibility and damage
  float feetOffset = 5; // Offset for feet collision detection

  Player() {
    x = width / 2; // Start the player in the middle of the screen
    y = 0; // Start the player at the top of the screen
  }

  void update() {
    if (health <= 0) return; // Stop updating if the player is dead
    
    if (moveDir != 0) {
      x += moveDir * xSpeed; // Move the player horizontally
      x = constrain(x, 0, width - w); // Keep the player within the screen bounds
    }
    ySpeed += gravity; // Apply gravity to the player's ySpeed
    y += ySpeed; // Update the player's vertical position

    handlePlatformCollision(); // Check for collisions with platforms
    handleCeilingBottomCollision(); // Check for collisions with the ceiling and bottom of the screen
    handleInvincibleAndDamage(); // Handle invincibility and damage states
    updateAnimation(); // Update the player's animation
  }

  void handlePlatformCollision() {
    for (Platform platform : platforms) {
      // if (platform.y > y && platform.y < y + h) { // Check if the player is above the platform
      //   if (x + w > platform.x && x < platform.x + platform.w) { // Check if the player is within the platform's horizontal bounds
      // use the AABB function to check for collision
      if (AABB(x, y+h-feetOffset, w, feetOffset, platform.x, platform.y, platform.w, platform.h)) {
        platform.interact(this); // Interact with the platform
      }
    }
  }

  void handleCeilingBottomCollision() {
    if (y < 0 || y > height) {
      y = 0; // Prevent the player from going above the top of the screen
      ySpeed = 0; // Reset the player's ySpeed
      takeDamage(1); // Take damage if the player goes off-screen
    }
  }

  // handle player damage
  void takeDamage(int damage) {
    // If the player is not invincible and not already damaged, reduce health
    if (!invincible && !damaged) {
      health -= damage; // Reduce health by the damage amount
      damaged = true; // Trigger damage state
      damageTimer = DAMAGE_BLINK_DURATION; // Set the damage timer
    }
  }

  boolean AABB(float ax, float ay, float aw, float ah, float bx, float by, float bw, float bh) {
    // Axis-Aligned Bounding Box (AABB) collision detection
    return (ax < bx + bw && ax + aw > bx && ay < by + bh && ay + ah > by);
  }
  // handle invincibility and damage states
  void handleInvincibleAndDamage() {
    if (invincible) {
      invincibilityTimer = max(0, invincibilityTimer - 1);
      if (invincibilityTimer == 0) invincible = false;
    }
    if (damaged) {
      damageTimer = max(0, damageTimer - 1);
      if (damageTimer == 0) damaged = false;
    }
  }

  void updateAnimation() {
    if (moveDir != 0) {
      // every ANIMATION_INTERVAL frames, show the next frame of the animation
      if (frameCount % ANIMATION_INTERVAL == 0) {
        animatedFrameIndex = (animatedFrameIndex + 1) % playerSprites[spriteIndex].length; // Cycle through animation frames
      }
    } else {
      animatedFrameIndex = 0; // Reset to the idle frame when not moving
    }
  }

  void display() {
    PImage currentImage = playerSprites[spriteIndex][animatedFrameIndex];
    if (invincible && frameCount % 20 < 10) {
      tint(255, 126);
    } else if (damaged && frameCount % 10 < 5) {
      tint(255, 0, 0);
    } else {
      noTint();
    }
    image(currentImage, x, y, w, h);
    noTint();
  }

  void setMovement(int dir) {
    // Set the movement direction
    moveDir = dir;
    // Update the sprite index based on direction
    spriteIndex = (moveDir < 0) ? 1 : (moveDir > 0) ? 2 : 0; // Update the sprite index based on direction
    //println(spriteIndex, moveDir);
  }

  void forceDropToBottom() {
    updateAnimation(); // Still update the animation while falling
    ySpeed += gravity; // Apply gravity to the player's ySpeed
    y += ySpeed; // Update the player's vertical position
    if (y > height) {
      y = height;
    }
  }

}
