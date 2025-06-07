import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter_super_marknel/supermarknel.dart';

class JumpButton extends SpriteComponent
    with HasGameRef<SuperMarknel>, TapCallbacks, DoubleTapCallbacks {
  JumpButton();

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('Controls/JumpButton.png'));
    size = Vector2(game.cameraWidth / 6, game.cameraHeight / 4);
    position = Vector2(
        game.cameraWidth - size.x - 80, game.cameraHeight - size.y - 80);

    // size = Vector2(game.size.x / 0.03, game.size.y - 160);
    priority = 2;
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.tumalonKaNaBa = true;
    super.onTapDown(event);
  }

  @override
  void onDoubleTapDown(DoubleTapDownEvent event) {
    game.player.checkForDoubleJump();
    super.onDoubleTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.player.tumalonKaNaBa = false;
    super.onTapUp(event);
  }
}
