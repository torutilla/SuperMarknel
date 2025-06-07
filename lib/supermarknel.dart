import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_super_marknel/Loading%20Screen/countLives.dart';
// import 'package:flutter_super_marknel/Loading%20Screen/loading.dart';
import 'package:flutter_super_marknel/components/actors/player.dart';
import 'package:flutter_super_marknel/components/jumpButton.dart';
import 'package:flutter_super_marknel/components/levels/level.dart';
import 'package:flutter_super_marknel/otherscreens/flamerouter.dart';
import 'package:restart_app/restart_app.dart';

class SuperMarknel extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  late final JoystickComponent joystick;
  Color backgroundColor() => const Color(0xFF6A6AFF);
  late TiledComponent level;
  bool enableJoyStick = true;
  List<String> levelNames = ['Level-01', 'Level-02', 'Level-03'];
  int currLevel = 0;
  bool enableJoystick = true;
  late Level myWorld;
  late Player player;
  static const id = 'game';
  double cameraWidth = 1640;
  double cameraHeight = 730;

  late final flameRouter gameRouter;

  @override
  FutureOr<void> onLoad() async {
    gameRouter = flameRouter();

    try {
      await images.loadAllImages();
      player = Player();

      await _loadCurrentLevel();
    } catch (e) {
      print("error $e");
    }
    return super.onLoad();
  }

  @override
  void update(double dt) {
    updateJoystick();
    super.update(dt);
  }

  void addJoystick() async {
    joystick = JoystickComponent(
      priority: 2,
      knob: SpriteComponent(
          sprite: Sprite(images.fromCache('Controls/knob.png')),
          size: Vector2(160, 160)),
      anchor: Anchor.center,
      background: SpriteComponent(
        sprite: Sprite(images.fromCache('Controls/joy.png')),
        size: Vector2(240, 240),
      ),
      margin: const EdgeInsets.only(left: 60, bottom: 60),
    );
  }

  void updateJoystick() async {
    //movement sa joystick
    if (isMounted) {
      if (enableJoyStick) {
        if (player.pwedeNaBaGumalaw) {
          switch (joystick.direction) {
            case JoystickDirection.left:
            case JoystickDirection.downLeft:
            case JoystickDirection.upLeft:
              player.horizontalMovement = -5;
              // print(player.direction);
              break;
            case JoystickDirection.right:
            case JoystickDirection.downRight:
            case JoystickDirection.upRight:
              player.horizontalMovement = 5;
              break;
            default:
              player.horizontalMovement = 0;
              // print(player.direction);
              break;
          }
        }
      }
    }
  }

  void loadLevels() async {
    removeWhere((component) => component is Level);

    if (currLevel < levelNames.length - 1) {
      currLevel++;
      player.pwedeNaBaGumalaw = false;
    } else {
      // no more levels
      currLevel = 0;
    }
    await _reloadCurrentLevel();
  }

  Future<void> _reloadCurrentLevel() async {
    remove(world);
    await world.remove;
    remove(camera);
    await camera.remove;
    await Future.delayed(Duration(milliseconds: 500));
    if (myWorld != null) {
      await _loadCurrentLevel();
      Future.delayed(
          Duration(seconds: 1), () => player.pwedeNaBaGumalaw = true);
    }
  }

  Future<void> _loadCurrentLevel() async {
    try {
      print('Creating new level: ${levelNames[currLevel]}');
      myWorld = Level(levelName: levelNames[currLevel], player: player);
      CameraComponent camera = CameraComponent.withFixedResolution(
        world: myWorld!,
        width: cameraWidth,
        height: cameraHeight,
      );
      camera.viewfinder.zoom = 2.5;
      camera.viewfinder.anchor = Anchor.center;
      addAll([myWorld!, camera]);
      await myWorld!.loaded;
      camera.setBounds(myWorld!.levelBounds);
      level = myWorld.level;
      camera.follow(player);
      if (enableJoyStick && currLevel == 0) {
        addJoystick();
      }
      camera.viewport.add(JumpButton());
      camera.viewport.add(joystick);
      // camera.viewport.add(
      //   Lives(
      //     position: Vector2(cameraWidth, cameraHeight),
      //   ),
      // );
      player.startPosition = Vector2(player.position.x, player.position.y);
      print('New level added: ${levelNames[currLevel]}');
    } catch (e) {
      print('Error loading level: $e');
    }
  }

  // void _handleLivesDepleted() {
  //   Restart.restartApp();
  // }
}
