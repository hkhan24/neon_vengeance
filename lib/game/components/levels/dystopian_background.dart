import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import '../../neon_vengeance_game.dart';

class DystopianBackground extends ParallaxComponent<NeonVengeanceGame> {
  DystopianBackground() : super(priority: -1);
  @override
  Future<void> onLoad() async {
    parallax = await game.loadParallax(
      [
        ParallaxImageData('background.png'),
      ],
      baseVelocity: Vector2(20, 0),
      velocityMultiplierDelta: Vector2(1.5, 1.0),
      // Scale it to fully fill the layer depending on orientation
      fill: LayerFill.height,
    );
  }
}
