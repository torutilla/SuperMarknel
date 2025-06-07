import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'package:flutter_super_marknel/components/actors/player.dart';
import 'package:flutter_super_marknel/components/customhitbox.dart';
import 'package:flutter_super_marknel/supermarknel.dart';

enum ChomperState { idle, attack, hit }

class Chomper extends SpriteAnimationGroupComponent
    with HasGameRef<SuperMarknel>, CollisionCallbacks {
  final double offNeg;
  final double offPos;
  Chomper({super.position, super.size, this.offNeg = 0, this.offPos = 0});

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation attackAnimation;
  late final SpriteAnimation hitAnimation;

  final double stepTime1 = 0.10;
  final double stepTime2 = 0.20;
  final double tileSize = 40;
  late double targetDirection = -1;
  final double bounceJump = 260;
  late Player player;

  late final double rangeChomperPos;
  late final double rangeChomperNeg;

  bool isHit = false;

  final hitbox = customHitBox(
    offsetX: 0,
    offsetY: 10,
    width: 120,
    height: 70,
  );

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
      collisionType: CollisionType.active,
    ));
    // debugMode = true;
    player = game.player;
    loadAnimations();
    _checkRangeChomper();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!isHit) {
      chomperDirection();
      updateChomperState();
    }
    super.update(dt);
  }

  void loadAnimations() {
    idleAnimation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Enemies/Chomper/Idle (82x64).png'),
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: stepTime2,
          textureSize: Vector2(82, 64),
        ));
    attackAnimation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Enemies/Chomper/Attack (120x65).png'),
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: stepTime1,
          textureSize: Vector2(120, 65),
        ));
    hitAnimation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Enemies/Chomper/Hit (120x65).png'),
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: stepTime1,
          textureSize: Vector2(120, 65),
          loop: false,
        ));

    animations = {
      ChomperState.idle: idleAnimation,
      ChomperState.attack: attackAnimation,
      ChomperState.hit: hitAnimation,
    };

    current = ChomperState.idle;
  }

  void _checkRangeChomper() {
    rangeChomperNeg = position.x - offNeg * tileSize;
    rangeChomperPos = position.x + offPos * tileSize;
  }

  void chomperDirection() {
    double chomperOffset = (scale.x > 0) ? 0 : -width;
    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;
    targetDirection =
        (player.x + playerOffset < position.x + chomperOffset) ? -1 : 1;
    if ((targetDirection < 0 && scale.x > 0) ||
        (targetDirection > 0 && scale.x < 0)) {
      flipHorizontallyAroundCenter();
    }
  }

  void updateChomperState() {
    if (isPlayerinRange()) {
      if (current != ChomperState.attack) {
        current = ChomperState.attack;
        size.x = 120;
      }
    } else {
      if (current != ChomperState.idle) {
        current = ChomperState.idle;
        size.x = 82;
      }
    }
  }

  bool isPlayerinRange() {
    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;
    return player.x + playerOffset >= rangeChomperNeg &&
        player.x + playerOffset <= rangeChomperPos &&
        player.y + player.height > position.y &&
        player.y < position.y + height;
  }

  void collideWithMarknel() async {
    if (player.velo.y > 0 && player.y + player.height > position.y) {
      isHit = true;
      current = ChomperState.hit;
      player.velo.y = -bounceJump;
      await animationTicker?.completed;
      removeFromParent();
    } else {
      player.collideWithEnemy();
    }
  }
}
