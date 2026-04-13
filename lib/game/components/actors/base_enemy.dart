import 'package:flame/components.dart';

mixin BaseEnemy on PositionComponent {
  void takeDamage(int amount);
}
