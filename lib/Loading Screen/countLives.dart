import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_super_marknel/Loading%20Screen/homeScreen.dart';
import 'package:flutter_super_marknel/otherscreens/flamerouter.dart';
import 'package:flutter_super_marknel/otherscreens/flamerouter.dart';
import 'package:flutter_super_marknel/routingMain.dart';
import 'package:flutter_super_marknel/supermarknel.dart';
import 'package:restart_app/restart_app.dart';

class Lives extends PositionComponent with HasGameRef<SuperMarknel> {
  Lives({
    super.position,
  });
  late final TextComponent text;
  late final SpriteComponent char;

  late final flameRouter Router;

  int lifecount = 3;

  @override
  FutureOr<void> onLoad() {
    Router = flameRouter();
    position = Vector2(position.x - 160, (position.y - position.y) + 100);
    loadImage();
    loadText();
    return super.onLoad();
  }

  void loadImage() async {
    final sprite = await Sprite.load('Character/Idle (80x80).png');
    char = SpriteComponent(
      sprite: sprite,
    );
    add(char);
  }

  void loadText() {
    text = TextComponent(
      text: 'x$lifecount',
      textRenderer: TextPaint(
        style: const TextStyle(fontFamily: 'Pixeboy'),
      ),
      scale: Vector2.all(3.0),
      position: Vector2(50, 20),
    );
    add(text);
  }

  @override
  Future<void> update(double dt) async {
    final player = gameRef.player;
    if (player.updateLife) {
      lifecount -= 1;
      text.text = 'x$lifecount';
      player.updateLife = false;
    }
    if (lifecount <= 0) {
      text.text = 'x0';
      // Restart.restartApp(webOrigin: 'mainscreen');
      // Navigator.of(context).popUntil((route) => false);
      // onLivesDepleted();
      Router.navigateToMainScreen();
    }
    super.update(dt);
  }
}
