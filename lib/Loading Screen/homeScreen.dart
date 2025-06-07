import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';

class MainRouting extends StatelessWidget {
  static const id = 'MainMenu';
  final VoidCallback? onPressed;
  MainRouting({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: LayoutBuilder(
          builder: (context, constraints) {
            double screenHeight = constraints.maxHeight;
            double screenWidth = constraints.maxWidth;

            double logoHeight = screenHeight * 0.6;
            double logoWidth = screenWidth * 0.8;
            double buttonHeight = screenHeight * 0.1;
            double buttonWidth = screenWidth * 0.7;

            return Stack(
              children: [
                Image.asset(
                  'assets/images/Tilesets/sky-background.png',
                  fit: BoxFit.cover,
                  height: screenHeight,
                  width: screenWidth,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/Logos/super marknel.png',
                      height: logoHeight,
                      width: logoWidth,
                      fit: BoxFit.contain,
                    ),
                    // SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: onPressed,
                        child: Image.asset(
                          'assets/images/Controls/playbutton.png',
                          height: buttonHeight,
                          width: buttonWidth,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
