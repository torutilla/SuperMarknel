import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_super_marknel/routingMain.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnimatedSplashScreen(
          splashIconSize: 160.0,
          splash: 'assets/images/Logos/cct-logo.png',
          duration: 3000,
          splashTransition: SplashTransition.fadeTransition,
          backgroundColor: Colors.black,
          nextScreen: const MyHomePage()),
      //   Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       Container(
      //         height: 100,
      //         width: 100,
      //         color: Colors.blue,
      //       ),
      //       const Text('Splash Screen',
      //           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      //     ],
      //   ),
      // ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnimatedSplashScreen(
        splashIconSize: 160.0,
        splash: 'assets/images/Logos/scs-logo.png',
        duration: 3000,
        splashTransition: SplashTransition.fadeTransition,
        backgroundColor: Colors.black,
        nextScreen: MyRouter(),
      ),
    );
  }
}
