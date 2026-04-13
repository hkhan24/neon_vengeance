import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameState {
  final int health;
  final int specialMeter;
  final int score;
  final int zombiesKilled;

  const GameState({
    this.health = 100,
    this.specialMeter = 0,
    this.score = 0,
    this.zombiesKilled = 0,
  });

  GameState copyWith({int? health, int? specialMeter, int? score, int? zombiesKilled}) {
    return GameState(
      health: health ?? this.health,
      specialMeter: specialMeter ?? this.specialMeter,
      score: score ?? this.score,
      zombiesKilled: zombiesKilled ?? this.zombiesKilled,
    );
  }
}

class GameStateNotifier extends Notifier<GameState> {
  @override
  GameState build() {
    return const GameState();
  }

  void resetState() {
    state = const GameState();
  }

  bool get isAlive => state.health > 0;

  void addScore(int points) {
    state = state.copyWith(score: state.score + points);
  }

  void incrementZombieKill() {
    state = state.copyWith(zombiesKilled: state.zombiesKilled + 1);
  }

  void fillSpecial(int amount) {
    final newSpecial = (state.specialMeter + amount).clamp(0, 100);
    state = state.copyWith(specialMeter: newSpecial);
  }

  void consumeSpecial() {
    state = state.copyWith(specialMeter: 0);
  }

  void takeDamage(int amount) {
    final newHealth = (state.health - amount).clamp(0, 100);
    state = state.copyWith(health: newHealth);
  }
}

final gameStateProvider = NotifierProvider<GameStateNotifier, GameState>(() {
  return GameStateNotifier();
});
