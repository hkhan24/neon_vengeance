import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../../neon_vengeance_game.dart';
import '../../../state/game_state.dart';
import '../levels/dystopian_background.dart';
import 'player.dart';
import 'base_enemy.dart';

class BigBossEnemy extends SpriteComponent with HasGameReference<NeonVengeanceGame>, CollisionCallbacks, BaseEnemy {
  double speed = 50; // Slower but deadlier
  int health = 200; // Roughly 10 standard hits, but Superpowers (100) will chunk him!
  final int maxHealth = 200;
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
    // Use the actual damage amount so Ultimates do massive damage!
    health -= amount;
    
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

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final barWidth = size.x * 0.6;
    const barHeight = 12.0;
    final xOffset = (size.x - barWidth) / 2;
    const yOffset = -20.0;
    
    // Background bar
    canvas.drawRect(
      Rect.fromLTWH(xOffset, yOffset, barWidth, barHeight),
      Paint()..color = Colors.red.withValues(alpha: 0.8),
    );
    
    // Foreground bar
    final healthPct = (health / maxHealth).clamp(0.0, 1.0);
    canvas.drawRect(
      Rect.fromLTWH(xOffset, yOffset, barWidth * healthPct, barHeight),
      Paint()..color = Colors.orangeAccent,
    );
  }
}
