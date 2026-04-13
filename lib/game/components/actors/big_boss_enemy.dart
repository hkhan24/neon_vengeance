import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/services.dart';
import '../../neon_vengeance_game.dart';
import '../../../state/game_state.dart';
import '../levels/dystopian_background.dart';
import 'player.dart';

class BigBossEnemy extends SpriteComponent with HasGameReference<NeonVengeanceGame>, CollisionCallbacks {
  double speed = 50; // Slower but deadlier
  int health = 10; // Requires exactly 10 hits
  double damageCooldown = 0;
  
  BigBossEnemy({required Vector2 position}) : super(position: position, size: Vector2(300, 300), anchor: Anchor.center) {
    add(RectangleHitbox(size: Vector2(200, 280), position: Vector2(50, 10)));
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Load big boss asset
    sprite = await game.loadSprite('big_boss.png');

    // Freeze background to create a locked-in boss arena
    final bg = game.children.whereType<DystopianBackground>().firstOrNull;
    if (bg != null) {
      bg.parallax?.baseVelocity = Vector2.zero();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (damageCooldown > 0) damageCooldown -= dt;
    
    final player = game.children.whereType<Player>().firstOrNull;
    if (player != null) {
      final diff = player.position - position;
      final dist = diff.length;
      if (dist > 100) { // Bigger attack range
        final direction = diff.normalized();
        position += direction * speed * dt;
        
        if (direction.x < 0 && !isFlippedHorizontally) {
          flipHorizontallyAroundCenter();
        } else if (direction.x > 0 && isFlippedHorizontally) {
          flipHorizontallyAroundCenter();
        }
      } else {
        if (damageCooldown <= 0 && game.ref.read(gameStateProvider.notifier).isAlive) {
          game.ref.read(gameStateProvider.notifier).takeDamage(30); // Boss does more damage
          damageCooldown = 1.0;
        }
      }
    }
  }

  void takeDamage(int amount) {
    HapticFeedback.heavyImpact();
    // Boss takes exactly 1 hit of damage per special strike regardless of generic damage amount
    health -= 1;
    
    // Size changes slightly on hit to show feedback
    scale = Vector2.all(0.95);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (isMounted) scale = Vector2.all(1.0);
    });

    if (health <= 0) {
      game.ref.read(gameStateProvider.notifier).addScore(1000);
      removeFromParent();
      // Trigger level two transition via game
      game.startLevelTwo();
    }
  }
}
