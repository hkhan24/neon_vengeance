import 'package:flame/components.dart';
import 'player.dart';
import '../skills/joke_bomb.dart';
import '../../../state/game_state.dart';

class ChaosJester extends Player {
  final Vector2? initialPosition;
  
  ChaosJester({this.initialPosition});

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Load individual per-state images (clean single sprites, no grid slicing)
    final idleImg = await game.images.load('jester_idle.png');
    final walkImg = await game.images.load('jester_walk.png');
    final attackImg = await game.images.load('jester_attack.png');

    animations = {
      PlayerState.idle: SpriteAnimation.spriteList(
        [Sprite(idleImg)], stepTime: double.infinity,
      ),
      PlayerState.walk: SpriteAnimation.spriteList(
        [Sprite(walkImg)], stepTime: double.infinity,
      ),
      PlayerState.attack: SpriteAnimation.spriteList(
        [Sprite(attackImg)], stepTime: 0.3, loop: false,
      ),
      PlayerState.special: SpriteAnimation.spriteList(
        [Sprite(attackImg)], stepTime: 0.3, loop: false,
      ),
    };

    current = PlayerState.idle;

    if (initialPosition != null) {
      position = initialPosition!;
    } else {
      position = Vector2(250, game.size.y - 150);
    }
    scale = Vector2.all(1.5);
  }

  @override
  void tapAttack() {
    final bomb = JokeBomb(
      position: position.clone() + Vector2(isFlippedHorizontally ? -50 : 50, -20),
      direction: isFlippedHorizontally ? -1 : 1,
    );
    game.add(bomb);
  }

  @override
  void specialAttack() {
    game.ref.read(gameStateProvider.notifier).consumeSpecial();
    // Laughing Gas AoE Logic
  }
}
