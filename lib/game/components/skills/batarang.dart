import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../../neon_vengeance_game.dart';
import '../../../state/game_state.dart';
import '../actors/base_enemy.dart';

class Batarang extends SpriteComponent with HasGameReference<NeonVengeanceGame>, CollisionCallbacks {
  final double direction;
  double speed = 600;
  double _rotation = 0;

  Batarang({required Vector2 position, required this.direction}) 
    : super(position: position, size: Vector2(48, 28), anchor: Anchor.center) {
      add(RectangleHitbox(size: Vector2(48, 28)));
    }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = Sprite(await game.images.load('batarang.png'));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x += direction * speed * dt;
    
    // Spin rotation for that classic batarang effect
    _rotation += dt * 15;
    angle = _rotation;
    
    if (position.x < 0 || position.x > game.size.x) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is BaseEnemy) {
      other.takeDamage(15);
      removeFromParent();
      game.ref.read(gameStateProvider.notifier).fillSpecial(20);
    }
  }
}
