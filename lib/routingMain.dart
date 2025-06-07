import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter_super_marknel/Loading%20Screen/countLives.dart';
import 'package:flutter_super_marknel/Loading%20Screen/homeScreen.dart';

import 'package:flutter/material.dart';

import 'package:flutter_super_marknel/supermarknel.dart';

class MyRouter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: MainRouting.id,
      routes: {
        MainRouting.id: (context) =>
            MainRouting(onPressed: () => _navigateToGame(context)),
        SuperMarknel.id: (context) => GameWidget(
              game: SuperMarknel(),
            ),
      },
    );
  }

  void _navigateToGame(BuildContext context) {
    Navigator.pushNamed(context, SuperMarknel.id);
  }

  void navigateToMain(BuildContext context) {
    Navigator.pushReplacementNamed(context, MainRouting.id);
  }
}
