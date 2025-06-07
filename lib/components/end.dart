import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_super_marknel/components/customhitbox.dart';
import 'package:flutter_super_marknel/supermarknel.dart';

class EndPoint extends SpriteAnimationComponent
    with HasGameRef<SuperMarknel>, CollisionCallbacks {
  EndPoint({super.position, super.size});
  final hitbox = customHitBox(
    offsetX: 40,
    offsetY: 0,
    width: 40,
    height: 160,
  );
  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(
        hitbox.width,
        height,
      ),
      collisionType: CollisionType.passive,
    ));
    return super.onLoad();
  }

  void goToNextLevel() {
    game.loadLevels();
  }
}
