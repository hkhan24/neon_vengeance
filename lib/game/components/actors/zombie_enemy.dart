import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../../neon_vengeance_game.dart';
import '../../../state/game_state.dart';
import 'player.dart';

class ZombieEnemy extends SpriteAnimationComponent with HasGameReference<NeonVengeanceGame>, CollisionCallbacks {
  double speed = 100;
  int health = 30;
  double damageCooldown = 0;
  
  ZombieEnemy({required Vector2 position}) : super(position: position, size: Vector2(120, 120), anchor: Anchor.center) {
    add(RectangleHitbox(size: Vector2(80, 120), position: Vector2(20, 0)));
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Load a single clean sprite image (no grid slicing)
    final walkImg = await game.images.load('zombie_walk.png');

    animation = SpriteAnimation.spriteList(
      [Sprite(walkImg)], stepTime: double.infinity,
    );
    scale = Vector2.all(1.5);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (damageCooldown > 0) damageCooldown -= dt;
    
    final player = game.children.whereType<Player>().firstOrNull;
    if (player != null) {
      final diff = player.position - position;
      final dist = diff.length;
      if (dist > 50) {
        final direction = diff.normalized();
        position += direction * speed * dt;
        
        if (direction.x < 0 && !isFlippedHorizontally) {
          flipHorizontallyAroundCenter();
        } else if (direction.x > 0 && isFlippedHorizontally) {
          flipHorizontallyAroundCenter();
        }
      } else {
        if (damageCooldown <= 0 && game.ref.read(gameStateProvider.notifier).isAlive) {
          game.ref.read(gameStateProvider.notifier).takeDamage(10);
          damageCooldown = 1.0;
        }
      }
    }
  }

  void takeDamage(int amount) {
    health -= amount;
    if (health <= 0) {
      game.ref.read(gameStateProvider.notifier).addScore(50);
      removeFromParent();
    }
  }
}
