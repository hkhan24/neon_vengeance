import 'package:flame/components.dart';
import 'player.dart';
import '../skills/lasso_lash.dart';
import '../../../state/game_state.dart';

class DivineWarrior extends Player {
  @override
  Future<void> onLoad() async {
    super.onLoad();

    final idleImg = await game.images.load('warrior_idle.png');
    final walkImg = await game.images.load('warrior_walk.png');
    final attackImg = await game.images.load('warrior_attack.png');

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
    position = Vector2(100, game.size.y - 150);
    scale = Vector2.all(1.5);
  }

  @override
  void tapAttack() {
    final lasso = LassoLash(
      position: position.clone() + Vector2(isFlippedHorizontally ? -60 : 60, 0),
      direction: isFlippedHorizontally ? -1 : 1,
    );
    game.add(lasso);
  }

  @override
  void specialAttack() {
    game.ref.read(gameStateProvider.notifier).consumeSpecial();
    // Amazonian Shock: Ground slam causing massive radial damage
    // Handled via the game's triggerSpecial which already kills all zombies
  }
}
