import 'package:flame/components.dart';
import 'dart:math';
import '../components/actors/zombie_enemy.dart';
import '../components/actors/big_boss_enemy.dart';
import '../neon_vengeance_game.dart';
import '../../state/game_state.dart';

class EnemyManager extends Component with HasGameReference<NeonVengeanceGame> {
  final Random _random = Random();
  late Timer _timer;

  EnemyManager() {
    _timer = Timer(3, onTick: spawnZombie, repeat: true);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer.update(dt);
  }

  void spawnZombie() {
    if(!isMounted) return;

    final state = game.ref.read(gameStateProvider);

    // Trigger Big Boss after 10 zombie kills
    if (state.zombiesKilled >= 10 && !game.isBossSpawned && !game.isLevelTwo) {
      game.isBossSpawned = true;
      final yPos = game.size.y - 150;
      game.add(BigBossEnemy(position: Vector2(game.size.x + 150, yPos)));
      return;
    }

    // Stop spawning regular zombies during the boss fight
    if (game.isBossSpawned && !game.isLevelTwo) return;

    final yPos = game.size.y - 150 + _random.nextDouble() * 50 - 25; 
    // Spawn mostly on right but occasionally left
    final xPos = _random.nextBool() ? game.size.x + 100 : -100.0;
    
    game.add(ZombieEnemy(position: Vector2(xPos, yPos)));
  }
}
