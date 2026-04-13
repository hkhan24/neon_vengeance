import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../../neon_vengeance_game.dart';
import '../../../state/game_state.dart';
import '../actors/base_enemy.dart';

/// Lasso Lash: A whip-like projectile that extends outward, dealing damage
/// and pulling enemies closer. Travels a long distance before retracting.
class LassoLash extends SpriteComponent with HasGameReference<NeonVengeanceGame>, CollisionCallbacks {
  final double direction;
  double speed = 500;
  double lifeTime = 0.6;
  double _distanceTravelled = 0;
  final double maxDistance = 350;
  bool _returning = false;
  final Set<BaseEnemy> _hitEnemies = {};

  LassoLash({required Vector2 position, required this.direction})
    : super(
        position: position,
        size: Vector2(120, 50),
        anchor: Anchor.centerLeft,
      ) {
    add(RectangleHitbox(size: Vector2(120, 50)));
    // Flip if facing left
    if (direction < 0) {
      flipHorizontallyAroundCenter();
    }
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = Sprite(await game.images.load('lasso.png'));
  }

  @override
  void update(double dt) {
    super.update(dt);
    lifeTime -= dt;

    if (!_returning) {
      // Extend outward
      final move = speed * dt * direction;
      position.x += move;
      _distanceTravelled += move.abs();

      if (_distanceTravelled >= maxDistance) {
        _returning = true;
      }
    } else {
      // Retract (shorter phase)
      position.x -= speed * 1.5 * dt * direction;
    }

    if (lifeTime <= 0) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is BaseEnemy && !_hitEnemies.contains(other)) {
      _hitEnemies.add(other);
      other.takeDamage(18);
      // Pull enemy closer (towards the player's direction)
      other.position.x -= direction * 60;
      game.ref.read(gameStateProvider.notifier).fillSpecial(15);
    }
  }
}
