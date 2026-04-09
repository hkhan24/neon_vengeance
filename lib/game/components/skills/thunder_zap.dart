import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../../neon_vengeance_game.dart';
import '../../../state/game_state.dart';
import '../actors/zombie_enemy.dart';

/// Thunder Zap: A homing chain-lightning bolt that seeks the nearest enemy.
/// On hit, it chains to nearby enemies for devastating multi-target damage.
class ThunderZap extends SpriteComponent with HasGameReference<NeonVengeanceGame>, CollisionCallbacks {
  double lifeTime = 1.2;
  int chainsRemaining;
  double speed = 450;
  bool _hasHit = false;

  ThunderZap({required Vector2 position, this.chainsRemaining = 4})
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
      return;
    }

    if (_hasHit) return;

    // Home towards nearest zombie
    final zombies = game.children.whereType<ZombieEnemy>();
    if (zombies.isEmpty) {
      // No targets — keep flying forward
      position.x += speed * dt;
      if (position.x > game.size.x + 100) {
        removeFromParent();
      }
      return;
    }

    final nearest = zombies.reduce((a, b) =>
      (a.position - position).length < (b.position - position).length ? a : b);

    final diff = nearest.position - position;
    final dist = diff.length;

    if (dist > 5) {
      final dir = diff.normalized();
      position += dir * speed * dt;
      // Rotate sprite to face target
      angle = dir.screenAngle();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is ZombieEnemy && !_hasHit) {
      _hasHit = true;
      other.takeDamage(25);
      game.ref.read(gameStateProvider.notifier).fillSpecial(25);
      
      // Chain to nearest other zombie within range
      if (chainsRemaining > 0) {
        final zombies = game.children.whereType<ZombieEnemy>()
            .where((z) => z != other && (z.position - position).length < 350);
        if (zombies.isNotEmpty) {
          game.add(ThunderZap(position: position.clone(), chainsRemaining: chainsRemaining - 1));
        }
      }
      removeFromParent();
    }
  }
}
