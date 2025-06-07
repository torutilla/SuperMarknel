import 'package:flame/flame.dart';
import 'package:flame/game.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_super_marknel/Loading%20Screen/loading.dart';
import 'package:flutter_super_marknel/supermarknel.dart';
import 'package:restart_app/restart_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  runApp(MyApp());
  // SuperMarknel myGame = SuperMarknel(); //game instance
  // runApp(GameWidget(game: myGame));
}
