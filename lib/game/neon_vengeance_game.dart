import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'components/levels/dystopian_background.dart';
import 'components/actors/player.dart';
import 'components/actors/vigilante.dart';
import 'components/actors/chaos_jester.dart';
import 'components/actors/divine_warrior.dart';
import 'components/actors/bolt_speedster.dart';
import 'components/actors/zombie_enemy.dart';
import 'managers/enemy_manager.dart';
import 'package:flame_audio/flame_audio.dart';
import '../state/game_state.dart';

enum HeroType { vigilante, jester, warrior, speedster }

class NeonVengeanceGame extends FlameGame with HasCollisionDetection {
  final WidgetRef ref;
  final HeroType heroType;
  
  NeonVengeanceGame(this.ref, this.heroType);

  Vector2 joystickDelta = Vector2.zero();
  bool isAttacking = false;
  bool doSpecial = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Reset state for fresh game
    ref.read(gameStateProvider.notifier).resetState();

    // Add backgrounds
    add(DystopianBackground());
    
    // Add selected hero
    switch (heroType) {
      case HeroType.vigilante:
        add(Vigilante());
        break;
      case HeroType.jester:
        add(ChaosJester(initialPosition: Vector2(100, size.y - 150)));
        break;
      case HeroType.warrior:
        add(DivineWarrior());
        break;
      case HeroType.speedster:
        add(BoltSpeedster());
        break;
    }
    
    // Add Enemy Manager
    add(EnemyManager());

    // Background Music
    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play('bgm.wav', volume: 0.5);
  }

  void updateJoystick(Vector2 delta) {
    joystickDelta = delta;
  }

  void tapAttack() {
    isAttacking = true;
  }

  void triggerSpecial() {
    doSpecial = true;
    
    // Fear Strike AoE damage to all zombies
    final zombies = children.whereType<ZombieEnemy>();
    for (var z in zombies) {
      z.takeDamage(100); // 1-hit kill for mobs in radius (assume infinite radius for now)
    }
  }
}
