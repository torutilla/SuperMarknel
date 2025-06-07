import 'package:flame/components.dart';

class CollisionClass extends PositionComponent {
  bool isPlatform;
  CollisionClass({super.position, super.size, this.isPlatform = false}) {
    // debugMode = true;
  }
}
