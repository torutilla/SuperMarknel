import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_super_marknel/components/customhitbox.dart';
import 'package:flutter_super_marknel/supermarknel.dart';

class collectMe extends SpriteAnimationComponent
    with HasGameRef<SuperMarknel>, CollisionCallbacks {
  final String collect;
  collectMe({this.collect = 'Keys', position, size})
      : super(position: position, size: size);

  final hitbox = customHitBox(
    offsetX: 7,
    offsetY: 7,
    width: 26,
    height: 67,
  );

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(
        hitbox.width,
        hitbox.height,
      ),
      collisionType: CollisionType.passive,
    ));
    animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Collect/$collect.png'),
        SpriteAnimationData.sequenced(
          amount: 8,
          stepTime: 0.15,
          textureSize: Vector2(40, 80),
        ));
    return super.onLoad();
  }

  void collideWithPlayer() async {
    animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Collect/Keys Disappear.png'),
        SpriteAnimationData.sequenced(
          amount: 8,
          stepTime: 0.08,
          textureSize: Vector2(40, 80),
          loop: false,
        ));
    await animationTicker?.completed;
    removeFromParent();
  }
}
