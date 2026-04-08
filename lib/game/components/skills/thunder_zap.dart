import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../../neon_vengeance_game.dart';
import '../../../state/game_state.dart';
import '../actors/zombie_enemy.dart';

/// Thunder Zap: Instant chain-lightning strike that jumps between nearby enemies.
class ThunderZap extends SpriteComponent with HasGameReference<NeonVengeanceGame>, CollisionCallbacks {
  double lifeTime = 0.3;
  int chainsRemaining;

  ThunderZap({required Vector2 position, this.chainsRemaining = 3})
    : super(
        position: position,
        size: Vector2(48, 64),
        anchor: Anchor.center,
      ) {
    add(RectangleHitbox(size: Vector2(48, 64)));
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = Sprite(await game.images.load('thunder_zap.png'));
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
      other.takeDamage(20);
      game.ref.read(gameStateProvider.notifier).fillSpecial(25);
      
      // Chain to nearest other zombie
      if (chainsRemaining > 0) {
        final zombies = game.children.whereType<ZombieEnemy>()
            .where((z) => z != other && (z.position - position).length < 200);
        if (zombies.isNotEmpty) {
          final nearest = zombies.reduce((a, b) => 
            (a.position - position).length < (b.position - position).length ? a : b);
          game.add(ThunderZap(position: nearest.position.clone(), chainsRemaining: chainsRemaining - 1));
        }
      }
      removeFromParent();
    }
  }
}
