import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'components/levels/dystopian_background.dart';
import 'components/levels/forest_background.dart';
import 'components/actors/player.dart';
import 'components/actors/vigilante.dart';
import 'components/actors/chaos_jester.dart';
import 'components/actors/divine_warrior.dart';
import 'components/actors/bolt_speedster.dart';
import 'components/actors/base_enemy.dart';
import 'components/actors/zombie_enemy.dart';
import 'components/skills/special_effects.dart';
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
  bool isBossSpawned = false;
  bool isLevelTwo = false;

  void startLevelTwo() {
    isLevelTwo = true;
    
    // Remove old background
    children.whereType<DystopianBackground>().forEach((b) => b.removeFromParent());
    
    // Add new dark forest background
    add(ForestBackground());
    
    // Change music
    FlameAudio.bgm.play('level2_bgm.wav', volume: 0.5);
  }

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

    // Get player position for VFX origin
    final player = children.whereType<Player>().firstOrNull;
    final origin = player?.position.clone() ?? Vector2(size.x / 2, size.y / 2);

    // Spawn hero-specific visual effect
    switch (heroType) {
      case HeroType.vigilante:
        add(FearStrikeEffect(origin: origin));
        break;
      case HeroType.jester:
        add(LaughingGasEffect(origin: origin));
        break;
      case HeroType.warrior:
        add(AmazonianShockEffect(origin: origin));
        break;
      case HeroType.speedster:
        add(SupersonicVortexEffect(origin: origin));
        break;
    }
    
    // AoE damage to all enemies
    final enemies = children.whereType<BaseEnemy>();
    for (var e in enemies) {
      e.takeDamage(100);
    }
  }
}
