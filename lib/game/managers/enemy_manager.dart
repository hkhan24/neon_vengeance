import 'package:flame/components.dart';
import 'dart:math';
import '../components/actors/zombie_enemy.dart';
import '../neon_vengeance_game.dart';

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
    final yPos = game.size.y - 150 + _random.nextDouble() * 50 - 25; 
    // Spawn mostly on right but occasionally left
    final xPos = _random.nextBool() ? game.size.x + 100 : -100.0;
    
    game.add(ZombieEnemy(position: Vector2(xPos, yPos)));
  }
}
