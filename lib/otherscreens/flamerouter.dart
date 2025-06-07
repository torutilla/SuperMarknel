import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter_super_marknel/Loading%20Screen/homeScreen.dart';
import 'package:flutter_super_marknel/Loading%20Screen/loading.dart';
import 'package:flutter_super_marknel/otherscreens/gameover.dart';

class flameRouter extends Component {
  late final RouterComponent router;
  bool routerInitialized = false;
  final String route1 = 'mainscreen';
  final String route2 = 'loadingscreen';

  @override
  FutureOr<void> onLoad() {
    try {
      if (!routerInitialized) {
        router = RouterComponent(
          routes: {
            route1: OverlayRoute((context, game) => MainRouting()),
            route2: OverlayRoute((context, game) => MyApp()),
          },
          initialRoute: route1,
        );
        add(router);

        routerInitialized = true;
      }
    } catch (e, stackTrace) {
      print('Error initializing router: $e');
      print(stackTrace);
    }

    return super.onLoad();
  }

  void navigateToMainScreen() async {
    try {
      await onLoad(); // Ensure router is initialized

      if (routerInitialized && router != null) {
        router.pushNamed(route2);
      } else {
        print('Router not initialized or is null');
      }
    } catch (e) {
      print('Error during navigation: $e');
    }
  }
}
