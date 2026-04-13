import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import '../../neon_vengeance_game.dart';
import 'package:flutter/painting.dart';

class ForestBackground extends ParallaxComponent<NeonVengeanceGame> {
  @override
  Future<void> onLoad() async {
    super.onLoad();
    parallax = await game.loadParallax(
      [
        ParallaxImageData('level2_bg.png'),
      ],
      baseVelocity: Vector2(30, 0),
      velocityMultiplierDelta: Vector2.all(1.0),
      fill: LayerFill.height,
    );
  }
}
