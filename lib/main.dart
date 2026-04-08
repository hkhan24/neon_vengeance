import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game/neon_vengeance_game.dart';
import 'ui/game_overlay.dart';
import 'ui/character_selection.dart';

void main() {
  runApp(
    const ProviderScope(
      child: NeonVengeanceApp(),
    ),
  );
}

class NeonVengeanceApp extends ConsumerWidget {
  const NeonVengeanceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Neon Vengeance',
      theme: ThemeData.dark(),
      home: const CharacterSelectionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GameScreen extends ConsumerStatefulWidget {
  final HeroType heroType;

  const GameScreen({super.key, required this.heroType});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late NeonVengeanceGame game;

  @override
  void initState() {
    super.initState();
    game = NeonVengeanceGame(ref, widget.heroType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: game),
          GameOverlay(game: game),
        ],
      ),
    );
  }
}
