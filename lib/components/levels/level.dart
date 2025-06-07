import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter_super_marknel/components/actors/boar.dart';
import 'package:flutter_super_marknel/components/actors/car.dart';
import 'package:flutter_super_marknel/components/actors/chomper.dart';
import 'package:flutter_super_marknel/components/actors/player.dart';
import 'package:flutter_super_marknel/components/actors/powerup.dart';
import 'package:flutter_super_marknel/components/actors/slime.dart';
import 'package:flutter_super_marknel/components/collect.dart';
import 'package:flutter_super_marknel/components/end.dart';

import 'package:flutter_super_marknel/components/levels/collision.dart';
import 'package:flutter_super_marknel/components/spikeTrap.dart';
import 'package:flutter_super_marknel/components/spinnerTrap.dart';
import 'package:flutter_super_marknel/supermarknel.dart';

class Level extends World with HasGameRef<SuperMarknel> {
  final String levelName;
  late Player player;
  Level({required this.levelName, required this.player}) : super(priority: 1);

  late TiledComponent level;
  List<CollisionClass> collisionBlocks = [];
  late Rectangle levelBounds;

  @override
  FutureOr<void> onLoad() async {
    try {
      level = await TiledComponent.load('$levelName.tmx', Vector2.all(40));
      levelBounds = Rectangle.fromLTWH(
          0,
          0,
          (level.tileMap.map.width * level.tileMap.map.tileWidth).toDouble(),
          (level.tileMap.map.height * level.tileMap.map.tileHeight).toDouble());

      await add(level);

      _spawnPoints();
      _collisionsMethod();
      _collectSpawn();
      _spinnerTrap();
      _carSpawn();
      _powerup();

      return super.onLoad();
    } catch (e) {
      print('Error loading level: $e');
    }
  }

  Future<void> _spawnPoints() async {
    final spawnPointLayer =
        level.tileMap.getLayer<ObjectGroup>('PlayerPosition');
    if (spawnPointLayer != null) {
      for (final spawn in spawnPointLayer.objects) {
        switch (spawn.class_) {
          case 'Player':
            player.position = Vector2(spawn.x, spawn.y);
            final halfSize = Vector2(spawn.width, spawn.height) / 2;
            final minClamp = levelBounds.topLeft + halfSize;
            final maxClamp = levelBounds.bottomRight - halfSize;
            player.position.clamp(minClamp, maxClamp);
            await add(player);
            break;
          case 'Boar':
            final boar = Boar(
              position: Vector2(spawn.x, spawn.y),
              size: Vector2(spawn.width, spawn.height),
              offNeg: spawn.properties.getValue('offNeg'),
              offPos: spawn.properties.getValue('offPos'),
            );
            add(boar);
            break;
          case 'Chomper':
            final chomp = Chomper(
              position: Vector2(spawn.x, spawn.y),
              size: Vector2(spawn.width, spawn.height),
              offNeg: spawn.properties.getValue('offNeg'),
              offPos: spawn.properties.getValue('offPos'),
            );
            add(chomp);
            break;
          case 'Slime':
            final slime = Slime(
              position: Vector2(spawn.x, spawn.y),
              size: Vector2(spawn.width, spawn.height),
              offNeg: spawn.properties.getValue('offNeg'),
              offPos: spawn.properties.getValue('offPos'),
              jumpValue: spawn.properties.getValue('jumpValue'),
            );
            add(slime);
            break;
          default:
        }
      }
    }
  }

  void _collisionsMethod() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');
    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionClass(
                position: Vector2(collision.x, collision.y),
                size: Vector2(collision.width, collision.height),
                isPlatform: true);
            collisionBlocks.add(platform);
            add(platform);
            break;
          case 'SpikeTrap':
            final spike = SpikeTrap(
                position: Vector2(collision.x, collision.y),
                size: Vector2(collision.width, collision.height));
            add(spike);
            break;
          case 'End':
            final end = EndPoint(
                position: Vector2(collision.x, collision.y),
                size: Vector2(collision.width, collision.height));
            add(end);
          default:
            final terrain = CollisionClass(
                position: Vector2(collision.x, collision.y),
                size: Vector2(collision.width, collision.height));
            collisionBlocks.add(terrain);
            add(terrain);
        }
      }
    }
    player.collisionBlocks = collisionBlocks;
  }

  void _collectSpawn() {
    final collectionLayer = level.tileMap.getLayer<ObjectGroup>('Collections');
    if (collectionLayer != null) {
      for (final collect in collectionLayer.objects) {
        switch (collect.class_) {
          case 'Collect Key':
            final key = collectMe(
                collect: collect.name,
                position: Vector2(collect.x, collect.y),
                size: Vector2(collect.width, collect.height));
            add(key);
            break;
          default:
        }
      }
    }
  }

  void _spinnerTrap() {
    final spinnerTrapLayer = level.tileMap.getLayer<ObjectGroup>('SpinnerTrap');
    if (spinnerTrapLayer != null) {
      for (final spinner in spinnerTrapLayer.objects) {
        switch (spinner.class_) {
          case 'Spinner':
            final isVertical = spinner.properties.getValue('isVertical');
            final offsetNegative =
                spinner.properties.getValue('offsetNegative');
            final offsetPositive =
                spinner.properties.getValue('offsetPositive');
            final spinTrap = Spinner(
                isVertical: isVertical,
                offsetNegative: offsetNegative,
                offsetPositive: offsetPositive,
                position: Vector2(spinner.x, spinner.y),
                size: Vector2(spinner.width, spinner.height));
            add(spinTrap);
            break;
          default:
        }
      }
    }
  }

  void _carSpawn() {
    final carLayer = level.tileMap.getLayer<ObjectGroup>('CarLayer');
    if (carLayer != null) {
      for (final carspawn in carLayer.objects) {
        switch (carspawn.class_) {
          case 'Car':
            final offsetNegative = carspawn.properties.getValue('offNeg');
            final car = Car(
              position: Vector2(carspawn.x, carspawn.y + 75),
              size: Vector2(carspawn.width, carspawn.height),
              offNeg: offsetNegative,
            );
            add(car);
        }
      }
    }
  }

  void _powerup() {
    final powerUpLayer = level.tileMap.getLayer<ObjectGroup>('PowerUp');
    if (powerUpLayer != null) {
      for (final power in powerUpLayer.objects) {
        switch (power.class_) {
          case 'PowerUp':
            final powerUp = PowerUp(
                position: Vector2(power.x, power.y),
                size: Vector2(power.width, power.height));
            add(powerUp);
            break;
          default:
        }
      }
    }
  }
}
