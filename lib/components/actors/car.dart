import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_super_marknel/components/actors/player.dart';
import 'package:flutter_super_marknel/components/customhitbox.dart';
import 'package:flutter_super_marknel/supermarknel.dart';

class Car extends SpriteAnimationComponent
    with HasGameRef<SuperMarknel>, CollisionCallbacks {
  final double offNeg;
  Car({super.position, super.size, this.offNeg = 0});

  late final Player player;

  final double stepTime1 = 0.20;
  Vector2 velo = Vector2.zero();
  double carRangeNeg = 0;
  double tileSize = 40;
  double targetDirection = -1;
  double movementSpeed = 560;
  double bounceJump = 260;
  bool isHit = false;

  final hitbox = customHitBox(
    offsetX: 15,
    offsetY: 90,
    width: 255,
    height: 90,
  );

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    player = game.player;

    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
      collisionType: CollisionType.active,
    ));
    loadAnimations();
    calculateCarRange();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    updateMovement(dt);
    super.update(dt);
  }

  void loadAnimations() {
    animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Enemies/Car/Carro1.png'),
        SpriteAnimationData.sequenced(
          amount: 2,
          stepTime: stepTime1,
          textureSize: Vector2(300, 300),
        ));
  }

  void calculateCarRange() {
    carRangeNeg = position.x - offNeg * tileSize;
  }

  void updateMovement(dt) {
    velo.x = 0;
    if (isPlayerInRange()) {
      velo.x = targetDirection * movementSpeed;
    }
    position.x += velo.x * dt;
  }

  bool isPlayerInRange() {
    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;
    return player.x + playerOffset >= carRangeNeg &&
        player.y + player.height > position.y &&
        player.y < position.y + height;
  }

  void collideWithMarknel() {
    if (player.velo.y > 0 && player.y + player.height > position.y) {
      player.velo.y = -bounceJump;
    } else {
      player.collideWithEnemy();
    }
  }
}
