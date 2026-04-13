import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../../neon_vengeance_game.dart';
import '../../../state/game_state.dart';
import '../actors/base_enemy.dart';

class JokeBomb extends SpriteComponent with HasGameReference<NeonVengeanceGame>, CollisionCallbacks {
  final double direction;
  double velocityX = 400;
  double velocityY = -400; 
  final double gravity = 1200;
  double _rotation = 0;

  JokeBomb({required Vector2 position, required this.direction}) 
    : super(position: position, size: Vector2(40, 40), anchor: Anchor.center) {
      add(CircleHitbox(radius: 20, position: Vector2(0, 0)));
      velocityX *= direction; 
    }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = Sprite(await game.images.load('joke_bomb.png'));
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    velocityY += gravity * dt;

    position.x += velocityX * dt;
    position.y += velocityY * dt;
    
    // Tumble rotation
    _rotation += dt * 8;
    angle = _rotation;
    
    // Floor collision
    if (position.y >= game.size.y - 50) {
      explode();
    }
    
    if (position.x < 0 || position.x > game.size.x) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is BaseEnemy) {
      explode(hitDirectTarget: other);
    }
  }

  void explode({BaseEnemy? hitDirectTarget}) {
    final zombies = game.children.whereType<BaseEnemy>();
    bool hitAny = false;
    for (var z in zombies) {
      if ((z.position - position).length < 120) { 
        z.takeDamage(20);
        hitAny = true;
      }
    }
    
    if (hitDirectTarget != null && !hitAny) {
      hitDirectTarget.takeDamage(20);
      hitAny = true;
    }

    if (hitAny) {
      game.ref.read(gameStateProvider.notifier).fillSpecial(25);
    }
    
    removeFromParent();
  }
}
