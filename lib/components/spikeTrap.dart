import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_super_marknel/components/customhitbox.dart';

class SpikeTrap extends SpriteAnimationComponent with CollisionCallbacks {
  SpikeTrap({super.position, super.size});
  final hitbox = customHitBox(
    offsetX: 0,
    offsetY: 20,
    width: 20,
    height: 20,
  );
  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(
        width,
        hitbox.height,
      ),
      collisionType: CollisionType.passive,
    ));
    return super.onLoad();
  }
}
