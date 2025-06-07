import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_super_marknel/components/actors/player.dart';
import 'package:flutter_super_marknel/components/customhitbox.dart';
import 'package:flutter_super_marknel/components/levels/collision.dart';
import 'package:flutter_super_marknel/components/otherfunctions.dart';
import 'package:flutter_super_marknel/supermarknel.dart';

enum slimeState { jump, idle }

class Slime extends SpriteAnimationGroupComponent
    with HasGameRef<SuperMarknel>, CollisionCallbacks {
  final double offNeg;
  final double offPos;
  final double jumpValue;
  Slime({
    super.position,
    super.size,
    this.offNeg = 0,
    this.offPos = 0,
    this.jumpValue = 0,
  });

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation jumpAnimation;

  late final double rangeSlimeNeg;
  late final double rangeSlimePos;

  final double termVelo = 260.0;
  final double gravity = 9.8;
  double targetDirection = -1;
  double movementSpeed = 120;
  double bounceJump = 260;
  late final Vector2 initialPosition;

  bool limitHasReached = false;
  bool isOnGround = false;
  Vector2 velo = Vector2.zero();

  double tileSize = 40;
  final double stepTime2 = 0.20;

  late Player player;

  late final double jumpLimit;

  List<CollisionClass> collisionBlocks = [];

  final hitbox = customHitBox(
    offsetX: 10,
    offsetY: 10,
    width: 60,
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
    initialPosition = Vector2(position.x, position.y);
    jumpLimit = initialPosition.y + (-jumpValue * tileSize);

    loadAnimations();
    _checkRangeSlime();
    return super.onLoad();
  }

  void loadAnimations() {
    idleAnimation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Enemies/Slime/Idle (80x80).png'),
        SpriteAnimationData.sequenced(
          amount: 2,
          stepTime: stepTime2,
          textureSize: Vector2(80, 80),
        ));
    jumpAnimation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Enemies/Slime/Jump (80x80).png'),
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: 0.15,
          textureSize: Vector2(80, 80),
          loop: false,
        ));

    animations = {
      slimeState.idle: idleAnimation,
      slimeState.jump: jumpAnimation,
    };
    current = slimeState.idle;
  }

  @override
  void update(double dt) {
    updateSlimeJump(dt);

    updateSlimeState();

    super.update(dt);
  }

  void _checkRangeSlime() {
    rangeSlimeNeg = position.x - offNeg * tileSize;
    rangeSlimePos = position.x + offNeg * tileSize;
  }

  void updateSlimeJump(double dt) async {
    if (isPlayerinRange()) {
      if (!limitHasReached) {
        velo.y = -jumpValue * movementSpeed;
        position.y += velo.y * dt;

        if (position.y <= jumpLimit) {
          limitHasReached = true;
        }
      } else {
        velo.y = jumpValue * movementSpeed;
        position.y += velo.y * dt;

        if (position.y >= initialPosition.y) {
          position.y = initialPosition.y;
          limitHasReached = false;
        }
      }
    } else {
      if (position.y > initialPosition.y) {
        position.y = initialPosition.y;
      }
    }
  }

  // void _applyGravity(double dt) {
  //   velo.y += gravity;
  //   velo.y = velo.y.clamp(-jumpValue, initialPosition.y);
  //   position.y += velo.y;

  //   // limitHasReached = false;
  // }

  bool isPlayerinRange() {
    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;
    return player.x + playerOffset >= rangeSlimeNeg &&
            player.x + playerOffset <= rangeSlimePos &&
            player.y + player.height > position.y &&
            player.y < position.y + height ||
        position.y + jumpValue < player.y;
  }

  void updateSlimeState() {
    current = (velo.y < 0) ? slimeState.jump : slimeState.idle;
  }

  void collideWithMarknel() {
    if (player.velo.y > 0 && player.y + player.height > position.y) {
      player.velo.y = -bounceJump;
    } else if (player.y < position.y + height) {
      player.collideWithEnemy();
    }
  }
}
