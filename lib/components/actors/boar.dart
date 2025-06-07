import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_super_marknel/components/actors/player.dart';
import 'package:flutter_super_marknel/components/customhitbox.dart';
import 'package:flutter_super_marknel/supermarknel.dart';

enum boarState { idle, run, hit }

class Boar extends SpriteAnimationGroupComponent
    with CollisionCallbacks, HasGameRef<SuperMarknel> {
  final double offNeg;
  final double offPos;
  Boar({super.position, super.size, this.offNeg = 0, this.offPos = 0});

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;
  late final SpriteAnimation hitAnimation;

  final double stepTime1 = 0.15;
  final double stepTime2 = 0.25;
  final double tileSize = 40;
  final double movementSpeed = 250;
  final double bounceJump = 260;

  double boarRangeNeg = 0;
  double boarRangePos = 0;
  double moveDirection = 1;
  double targetDirection = -1;

  bool isHit = false;
  Vector2 velo = Vector2.zero();

  final hitbox = customHitBox(
    offsetX: 0,
    offsetY: 2,
    width: 80,
    height: 44,
  );

  late final Player player;

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
      collisionType: CollisionType.active,
    ));

    player = game.player;
    loadAnimations();
    calculateBoarRange();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!isHit) {
      _updateBoarState();
      _boarMovement(dt);
    }

    super.update(dt);
  }

  void loadAnimations() {
    idleAnimation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Enemies/Boar/Idle (80x46).png'),
        SpriteAnimationData.sequenced(
          amount: 2,
          stepTime: stepTime2,
          textureSize: Vector2(80, 46),
        ));
    runAnimation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Enemies/Boar/Run (80x46).png'),
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: stepTime1,
          textureSize: Vector2(80, 46),
        ));
    hitAnimation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Enemies/Boar/Hit (80x46).png'),
        SpriteAnimationData.sequenced(
          amount: 5,
          stepTime: stepTime1,
          textureSize: Vector2(80, 46),
          loop: false,
        ));

    animations = {
      boarState.idle: idleAnimation,
      boarState.run: runAnimation,
      boarState.hit: hitAnimation,
    };

    current = boarState.idle;
  }

  void calculateBoarRange() {
    boarRangeNeg = position.x - offNeg * tileSize;
    boarRangePos = position.x + offPos * tileSize;
  }

  void _boarMovement(dt) {
    velo.x = 0;

    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;
    double boarOffset = (scale.x > 0) ? 0 : -width;

    if (isPlayerInRange()) {
      targetDirection =
          (player.x + playerOffset < position.x + boarOffset) ? -1 : 1;

      velo.x = targetDirection * movementSpeed;
    }
    moveDirection = lerpDouble(moveDirection, targetDirection, 0.1) ?? 1;

    position.x += velo.x * dt;
  }

  bool isPlayerInRange() {
    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;
    return player.x + playerOffset >= boarRangeNeg &&
        player.x + playerOffset <= boarRangePos &&
        player.y + player.height > position.y &&
        player.y < position.y + height;
  }

  void _updateBoarState() {
    current = (velo.x != 0) ? boarState.run : boarState.idle;

    if ((moveDirection > 0 && scale.x < 0) ||
        (moveDirection < 0 && scale.x > 0)) {
      flipHorizontallyAroundCenter();
    }
  }

  void collideWithMarknel() async {
    if (player.velo.y > 0 && player.y + player.height > position.y) {
      isHit = true;
      current = boarState.hit;
      player.velo.y = -bounceJump;
      await animationTicker?.completed;
      removeFromParent();
    } else {
      player.collideWithEnemy();
    }
  }
}
