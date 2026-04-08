import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../../neon_vengeance_game.dart';
import '../../../state/game_state.dart';
import '../actors/zombie_enemy.dart';

/// Lasso Lash: A whip-like hit that pulls enemies closer.
class LassoLash extends SpriteComponent with HasGameReference<NeonVengeanceGame>, CollisionCallbacks {
  final double direction;
  double lifeTime = 0.25;

  LassoLash({required Vector2 position, required this.direction})
    : super(
        position: position,
        size: Vector2(100, 50),
        anchor: Anchor.centerLeft,
      ) {
    add(RectangleHitbox(size: Vector2(100, 50)));
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
    if (lifeTime <= 0) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is ZombieEnemy) {
      other.takeDamage(12);
      // Pull enemy closer (towards the player's direction)
      other.position.x -= direction * 40;
      game.ref.read(gameStateProvider.notifier).fillSpecial(15);
    }
  }
}
