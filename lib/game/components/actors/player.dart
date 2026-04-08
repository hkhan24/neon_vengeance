import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../../neon_vengeance_game.dart';

abstract class Player extends SpriteAnimationGroupComponent<PlayerState> with HasGameReference<NeonVengeanceGame>, CollisionCallbacks {
  double speed = 200;
  Vector2 velocity = Vector2.zero();
  double _walkBobTime = 0;
  double _baseY = 0;
  bool _baseYSet = false;

  Player() : super(size: Vector2(150, 150), anchor: Anchor.center) {
    add(RectangleHitbox(size: Vector2(80, 150), position: Vector2(35, 0)));
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    velocity = game.joystickDelta * speed;
    position += velocity * dt;

    // Bounds check
    position.x = position.x.clamp(0, game.size.x);
    position.y = position.y.clamp(game.size.y - 250, game.size.y - 50);

    // Track base Y for bob offset
    if (!_baseYSet && position.y > 0) {
      _baseY = position.y;
      _baseYSet = true;
    }

    if (game.isAttacking) {
      current = PlayerState.attack;
      game.isAttacking = false;
      tapAttack();
    } else if (game.doSpecial) {
      current = PlayerState.special;
      game.doSpecial = false;
      specialAttack();
    } else if (velocity.length > 0) {
      current = PlayerState.walk;
      if (velocity.x < 0 && !isFlippedHorizontally) {
        flipHorizontallyAroundCenter();
      } else if (velocity.x > 0 && isFlippedHorizontally) {
        flipHorizontallyAroundCenter();
      }
      // Walking bob animation
      _walkBobTime += dt * 10;
      position.y += sin(_walkBobTime) * 3;
    } else {
      current = PlayerState.idle;
      _walkBobTime = 0;
    }
  }

  void tapAttack();
  void specialAttack();
}

enum PlayerState { idle, walk, attack, hit, special }
