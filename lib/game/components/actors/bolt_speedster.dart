import 'package:flame/components.dart';
import 'player.dart';
import '../skills/thunder_zap.dart';
import '../../../state/game_state.dart';

class BoltSpeedster extends Player {
  BoltSpeedster() {
    speed = 350; // Fastest hero
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final idleImg = await game.images.load('speedster_idle.png');
    final walkImg = await game.images.load('speedster_walk.png');
    final attackImg = await game.images.load('speedster_attack.png');

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
    // Thunder Zap: instant chain-lightning on nearest zombie
    final zap = ThunderZap(
      position: position.clone() + Vector2(isFlippedHorizontally ? -80 : 80, 0),
    );
    game.add(zap);
  }

  @override
  void specialAttack() {
    game.ref.read(gameStateProvider.notifier).consumeSpecial();
    // Supersonic Vortex: suck in and destroy all nearby enemies
    // Handled by game's triggerSpecial
  }
}
