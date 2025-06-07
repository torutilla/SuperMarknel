import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/src/services/hardware_keyboard.dart';
import 'package:flutter_super_marknel/components/actors/boar.dart';
import 'package:flutter_super_marknel/components/actors/car.dart';
import 'package:flutter_super_marknel/components/actors/chomper.dart';
import 'package:flutter_super_marknel/components/actors/powerup.dart';
import 'package:flutter_super_marknel/components/actors/slime.dart';
import 'package:flutter_super_marknel/components/collect.dart';
import 'package:flutter_super_marknel/components/customhitbox.dart';
import 'package:flutter_super_marknel/components/end.dart';
import 'package:flutter_super_marknel/components/levels/collision.dart';
// import 'package:flutter_super_marknel/components/levels/level.dart';
import 'package:flutter_super_marknel/components/otherfunctions.dart';
import 'package:flutter_super_marknel/components/spikeTrap.dart';
import 'package:flutter_super_marknel/components/spinnerTrap.dart';
import 'package:flutter_super_marknel/supermarknel.dart';

enum marknelState {
  idle,
  gidle,
  run,
  grun,
  jump,
  gjump,
  fall,
  gfall,
  djump,
  gdjump,
  hit,
  appear,
}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<SuperMarknel>, KeyboardHandler, CollisionCallbacks {
  Player({position}) : super(position: position);

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;
  late final SpriteAnimation jumpAnimation;
  late final SpriteAnimation fallAnimation;
  late final SpriteAnimation godidleAnimation;
  late final SpriteAnimation godrunAnimation;
  late final SpriteAnimation godjumpAnimation;
  late final SpriteAnimation godfallAnimation;
  late final SpriteAnimation doubleJumpAnimation;
  late final SpriteAnimation goddoubleJumpAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearAnimation;

  final double stepTime1 = 0.2;
  final double stepTime2 = 0.15;
  double centerCamera = 0;
  double horizontalMovement = 0;
  bool isOnGround = false;
  bool tumalonKaNaBa = false;
  bool superMarknelOn = false;
  bool talonUli = false;
  bool isHit = false;
  bool leftKeyPress = false;
  bool rightKeyPress = false;
  bool enableJumpAnimation = false;
  bool pwedeNaBaGumalaw = true;
  Vector2 startPosition = Vector2.zero();
  final double gravity = 9.9;
  double jumpLimit = 340.0;
  final double termVelo = 260.0;
  double jumpPosition = 0;
  double speed = 100;
  bool updateLife = false;

  Vector2 velo = Vector2.zero();
  List<CollisionClass> collisionBlocks = [];
  customHitBox hitbox = customHitBox(
    offsetX: 2,
    offsetY: 1,
    width: 37,
    height: 80,
  );

  double fixedDelta = 1 / 60;
  double accumulatedTime = 0;

  //constants

  @override
  FutureOr<void> onLoad() {
    loadAllAnimations();

    add(RectangleHitbox(
        position: Vector2(
          hitbox.offsetX,
          hitbox.offsetY,
        ),
        size: Vector2(
          hitbox.width,
          hitbox.height,
        )));
    return super.onLoad();
  }

  @override
  void update(double dt) async {
    accumulatedTime += dt;
    while (accumulatedTime >= fixedDelta) {
      if (isOutOfBounds()) {
        superMarknelOn = false;

        _respawnPoint();
      } else {
        if (!isHit) {
          if (pwedeNaBaGumalaw) {
            _updateMovement(fixedDelta);
          }

          _updateMarknelState();
          _checkCollisions();
          _applyGravity(fixedDelta);
          _checkCollisionsV();
        }
      }
      accumulatedTime -= fixedDelta;
    }

    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    leftKeyPress = keysPressed.contains(LogicalKeyboardKey.keyA);
    rightKeyPress = keysPressed.contains(LogicalKeyboardKey.keyD);

    tumalonKaNaBa = keysPressed.contains(LogicalKeyboardKey.space);

    // if (leftKeyPress && rightKeyPress) {
    //   direction = marknelSanPunta.noDir;
    // } else if (leftKeyPress) {
    //   direction = marknelSanPunta.leftDir;
    // } else if (rightKeyPress) {
    //   direction = marknelSanPunta.rightDir;
    // } else {
    //   direction = marknelSanPunta.noDir;
    // }
    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is collectMe) other.collideWithPlayer();
    if (other is SpikeTrap) _respawnPoint();
    if (other is Spinner) _respawnPoint();
    if (other is Boar) other.collideWithMarknel();
    if (other is Chomper) other.collideWithMarknel();
    if (other is Car) other.collideWithMarknel();
    if (other is Slime) other.collideWithMarknel();
    if (other is PowerUp) other.collideWithMarknel();
    if (other is EndPoint) other.goToNextLevel();
    super.onCollisionStart(intersectionPoints, other);
  }

  void loadAllAnimations() {
    idleAnimation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Character/Idle (40x80).png'),
        SpriteAnimationData.sequenced(
          amount: 2,
          stepTime: stepTime1,
          textureSize: Vector2(40, 80),
        ));
    godidleAnimation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Character/God-Idle (40x80).png'),
        SpriteAnimationData.sequenced(
          amount: 2,
          stepTime: stepTime1,
          textureSize: Vector2(40, 80),
        ));

    runAnimation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Character/Run (44x80).png'),
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: stepTime2,
          textureSize: Vector2(44, 80),
        ));
    godrunAnimation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Character/God-Run (44x80).png'),
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: stepTime2,
          textureSize: Vector2(44, 80),
        ));

    jumpAnimation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Character/Jump (40x80).png'),
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: stepTime1,
          textureSize: Vector2(40, 80),
          loop: false,
        ));
    godjumpAnimation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Character/God-Jump (40x80).png'),
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: stepTime1,
          textureSize: Vector2(40, 80),
          loop: false,
        ));

    fallAnimation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Character/Fall (40x80).png'),
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: stepTime1,
          textureSize: Vector2(40, 80),
        ));
    godfallAnimation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Character/God-Fall (40x80).png'),
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: stepTime1,
          textureSize: Vector2(40, 80),
        ));

    doubleJumpAnimation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Character/Double Jump (40x80).png'),
        SpriteAnimationData.sequenced(
          amount: 2,
          stepTime: 0.2,
          textureSize: Vector2(40, 80),
          loop: false,
        ));
    goddoubleJumpAnimation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Character/God-Double Jump (40x80).png'),
        SpriteAnimationData.sequenced(
          amount: 2,
          stepTime: 0.2,
          textureSize: Vector2(40, 80),
          loop: false,
        ));
    hitAnimation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Character/Hit (40x80).png'),
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.08,
          textureSize: Vector2(40, 80),
          loop: false,
        ));
    appearAnimation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Character/Appearing (96x96).png'),
        SpriteAnimationData.sequenced(
          amount: 7,
          stepTime: 0.05,
          textureSize: Vector2(40, 80),
          loop: false,
        ));

    animations = {
      marknelState.idle: idleAnimation,
      marknelState.gidle: godidleAnimation,
      marknelState.run: runAnimation,
      marknelState.grun: godrunAnimation,
      marknelState.jump: jumpAnimation,
      marknelState.gjump: godjumpAnimation,
      marknelState.fall: fallAnimation,
      marknelState.gfall: godfallAnimation,
      marknelState.djump: doubleJumpAnimation,
      marknelState.gdjump: goddoubleJumpAnimation,
      marknelState.hit: hitAnimation,
      marknelState.appear: appearAnimation,
    };
    current = marknelState.idle;
  }

  void _updateMovement(double dt) {
    if (leftKeyPress || rightKeyPress) {
      updateDirection(dt);
    }
    if (tumalonKaNaBa && isOnGround) {
      jumpedMethod(dt);
    }
    if (superMarknelOn) {
      //kapag naka supermarknel sya, run to. bibilis at tataas ang talon
      speed = 200;
      jumpLimit = 440;
    } else {
      speed = 100;
      jumpLimit = 340;
    }

    velo.x = horizontalMovement * speed;
    position.x += velo.x * dt;
  }

  void checkForDoubleJump() {
    if (talonUli && !isOnGround && tumalonKaNaBa) {
      doubleJumpMethod();
    }
  }

  void jumpedMethod(double dt) {
    velo.y = -jumpLimit;
    position.y += velo.y * dt;
    jumpPosition = position.y;
    isOnGround = false;
    // tumalonKaNaBa = false;
    talonUli = true;
  }

  void doubleJumpMethod() async {
    enableJumpAnimation = true;

    velo.y = -jumpLimit;
    talonUli = false;
    tumalonKaNaBa = false;
    // isOnGround = false;
    // tumalonKaNaBa = false;
  }

  void updateDirection(double dt) {
    if (pwedeNaBaGumalaw) {
      if (leftKeyPress) {
        horizontalMovement += -5;
      } else if (rightKeyPress) {
        horizontalMovement += 5;
      }
    }
  }

  void _updateMarknelState() {
    marknelState state =
        superMarknelOn ? marknelState.gidle : marknelState.idle;

    if (velo.x < 0 && scale.x > 0) {
      //check naman kung san nakaharap si marknel
      flipHorizontallyAroundCenter();
    } else if (velo.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    if (velo.x > 0 || velo.x < 0) {
      state = superMarknelOn ? marknelState.grun : marknelState.run;
    }

    if (velo.y < 0) {
      state = superMarknelOn ? marknelState.gjump : marknelState.jump;
    } else if (velo.y > 0) {
      enableJumpAnimation = false;
      state = superMarknelOn ? marknelState.gfall : marknelState.fall;
    }

    if (enableJumpAnimation) {
      state = superMarknelOn ? marknelState.gdjump : marknelState.djump;
    }

    current = state;
  }

  void _checkCollisions() {
    for (final terrain in collisionBlocks) {
      if (!terrain.isPlatform) {
        if (checkForCollisions(this, terrain)) {
          if (velo.x > 0) {
            velo.x = 0;
            position.x = terrain.x - hitbox.offsetX - hitbox.width;

            break;
          }

          if (velo.x < 0) {
            velo.x = 0;
            position.x =
                terrain.x + terrain.width + hitbox.offsetX + hitbox.width;

            break;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velo.y += gravity;
    velo.y = velo.y.clamp(-jumpLimit, termVelo);
    position.y += velo.y * dt;
  }

  void _checkCollisionsV() {
    for (final terrain in collisionBlocks) {
      if (terrain.isPlatform) {
        if (checkForCollisions(this, terrain)) {
          if (velo.y > 0) {
            velo.y = 0;
            position.y = terrain.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
        }
      } else {
        if (checkForCollisions(this, terrain)) {
          if (velo.y > 0) {
            velo.y = 0;
            position.y = terrain.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }

          if (velo.y < 0) {
            velo.y = 0;
            position.y = terrain.y + terrain.height - hitbox.offsetY;
          }
        }
      }
    }
  }

  void _respawnPoint() async {
    game.enableJoyStick = false;
    pwedeNaBaGumalaw = false;
    current = marknelState.hit;
    isHit = true;

    await animationTicker?.completed;
    animationTicker?.reset();
    scale.x = 1;
    position = startPosition;

    current = marknelState.appear;

    await animationTicker?.completed;
    animationTicker?.reset();

    velo = Vector2.zero();
    position = startPosition;
    print(startPosition);

    isHit = false;

    if (isLoaded) {
      game.enableJoyStick = true;
      updateLife = true;
      Future.delayed(Duration(seconds: 1), () => pwedeNaBaGumalaw = true);
    }
  }

  void collideWithEnemy() {
    _respawnPoint();
    enableJumpAnimation = false;
  }

  bool isOutOfBounds() {
    return game.level.tileMap.map.width * 40 < position.x ||
        game.level.tileMap.map.height * 40 < position.y;
  }

  void powerUpMode() async {
    superMarknelOn = true;
    if (superMarknelOn) {
      Future.delayed(
        Duration(seconds: 20),
        () => {superMarknelOn = false, jumpLimit -= 100, speed -= 100},
      );
    }
  }
}
