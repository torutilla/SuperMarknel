import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_super_marknel/components/customhitbox.dart';
import 'package:flutter_super_marknel/supermarknel.dart';

class Spinner extends SpriteAnimationComponent
    with HasGameRef<SuperMarknel>, CollisionCallbacks {
  final bool isVertical;
  final double offsetNegative;
  final double offsetPositive;
  Spinner(
      {this.isVertical = false,
      this.offsetNegative = 0,
      this.offsetPositive = 0,
      position,
      size})
      : super(position: position, size: size);

  final hitbox = customHitBox(
    offsetX: 12,
    offsetY: 12,
    width: 58,
    height: 60,
  );

  static const movementSpeed = 200;
  static const tileSize = 40;
  double moveDirection = 1;
  double rangeNegative = 0;
  double rangePositive = 0;

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;

    if (isVertical) {
      rangeNegative = position.y - offsetNegative * tileSize;
      rangePositive = position.y + offsetPositive * tileSize;
    } else {
      rangeNegative = position.x - offsetNegative * tileSize;
      rangePositive = position.x + offsetPositive * tileSize;
    }

    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(
        hitbox.width,
        hitbox.height,
      ),
      collisionType: CollisionType.passive,
    ));
    animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Tilesets/spikes(80x80) (58x60)offset.png'),
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.10,
          textureSize: Vector2(80, 80),
        ));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isVertical) {
      _moveUpSpinner(dt);
    } else {
      _moveSideSpinner(dt);
    }

    super.update(dt);
  }

  void _moveUpSpinner(double dt) {
    if (position.y >= rangePositive) {
      moveDirection = -1;
    } else if (position.y <= rangeNegative) {
      moveDirection = 1;
    }
    position.y += moveDirection * movementSpeed * dt;
  }

  void _moveSideSpinner(double dt) {
    if (position.x >= rangePositive) {
      moveDirection = -1;
    } else if (position.x <= rangeNegative) {
      moveDirection = 1;
    }
    position.x += moveDirection * movementSpeed * dt;
  }
}
