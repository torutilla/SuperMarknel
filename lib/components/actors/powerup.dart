import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_super_marknel/components/actors/player.dart';
import 'package:flutter_super_marknel/components/customhitbox.dart';
import 'package:flutter_super_marknel/supermarknel.dart';

class PowerUp extends SpriteAnimationComponent with HasGameRef<SuperMarknel> {
  PowerUp({super.position, super.size});

  final hitbox = customHitBox(offsetX: 0, offsetY: 0, width: 80, height: 80);

  final double stepTime2 = 0.15;

  late Player player;

  bool isAlreadyHit = false;

  final targetPos = Vector2.zero();
  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height)));
    targetPos.y = position.y - 5;
    player = game.player;

    animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Tilesets/toyota-powerup.png'),
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: stepTime2,
          textureSize: Vector2(80, 80),
        ));
    return super.onLoad();
  }

  void collideWithMarknel() async {
    if (player.y + player.height > position.y + height) {
      if (!isAlreadyHit) {
        position.y = targetPos.y;
        player.velo.y = 0;
        player.y += 5;
        animation = SpriteAnimation.fromFrameData(
            game.images.fromCache('Tilesets/toyota-powerup-ishit.png'),
            SpriteAnimationData.sequenced(
              amount: 1,
              stepTime: stepTime2,
              textureSize: Vector2(80, 80),
              loop: false,
            ));
        await animationTicker?.completed;
        position.y += 5;
        player.powerUpMode();
      } else {
        player.velo.y = 0;
        player.y += 5;
      }
      isAlreadyHit = true;
    }
  }
}
