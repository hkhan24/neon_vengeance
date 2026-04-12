import 'package:flame/components.dart';
import 'player.dart';
import '../skills/batarang.dart';
import '../../../state/game_state.dart';

class Vigilante extends Player {
  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Load individual per-state images (clean single sprites, no grid slicing)
    final idleImg = await game.images.load('vigilante_idle.png');
    final walkImg = await game.images.load('vigilante_walk.png');
    final attackImg = await game.images.load('vigilante_attack.png');

    animations = {
      PlayerState.idle: SpriteAnimation.fromFrameData(
        idleImg,
        SpriteAnimationData.sequenced(amount: 16, stepTime: 0.1, textureSize: Vector2(idleImg.width / 4, idleImg.height / 4)),
      ),
      PlayerState.walk: SpriteAnimation.fromFrameData(
        walkImg,
        SpriteAnimationData.sequenced(amount: 16, stepTime: 0.1, textureSize: Vector2(walkImg.width / 4, walkImg.height / 4)),
      ),
      PlayerState.attack: SpriteAnimation.fromFrameData(
        attackImg,
        SpriteAnimationData.sequenced(amount: 16, stepTime: 0.05, textureSize: Vector2(attackImg.width / 4, attackImg.height / 4), loop: false),
      ),
      PlayerState.special: SpriteAnimation.fromFrameData(
        attackImg,
        SpriteAnimationData.sequenced(amount: 16, stepTime: 0.05, textureSize: Vector2(attackImg.width / 4, attackImg.height / 4), loop: false),
      ),
    };

    current = PlayerState.idle;

    position = Vector2(100, game.size.y - 150);
    scale = Vector2.all(1.5);
  }

  @override
  void tapAttack() {
    final batarang = Batarang(
      position: position.clone() + Vector2(isFlippedHorizontally ? -50 : 50, 0),
      direction: isFlippedHorizontally ? -1 : 1,
    );
    game.add(batarang); // Add the batarang to the game root.
  }

  @override
  void specialAttack() {
    // Consume Riverpod State
    game.ref.read(gameStateProvider.notifier).consumeSpecial();
    // Fear Strike AoE logic could go here.
  }
}
