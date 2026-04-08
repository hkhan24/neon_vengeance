import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame/components.dart';
import '../state/game_state.dart';
import '../game/neon_vengeance_game.dart';

class GameOverlay extends ConsumerWidget {
  final NeonVengeanceGame game;

  const GameOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameStateProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            // Top HUD
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('HP: ${state.health}/100', style: const TextStyle(color: Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                    Container(
                      width: 200,
                      height: 10,
                      color: Colors.red.withOpacity(0.3),
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 200 * (state.health.toDouble() / 100),
                        height: 10,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('SPECIAL: ${state.specialMeter}%', style: const TextStyle(color: Colors.blueAccent, fontSize: 16)),
                    Container(
                      width: 200,
                      height: 10,
                      color: Colors.blue.withOpacity(0.3),
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 200 * (state.specialMeter.toDouble() / 100),
                        height: 10,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
                Text('SCORE: ${state.score}', style: const TextStyle(color: Colors.yellow, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Virtual Joystick (D-PAD simple)
                _buildJoystick(),
                // Action Buttons
                Row(
                  children: [
                    FloatingActionButton(
                      heroTag: 'attackBtn',
                      backgroundColor: Colors.redAccent,
                      onPressed: () {
                        game.tapAttack();
                      },
                      child: const Icon(Icons.flash_on),
                    ),
                    const SizedBox(width: 16),
                    FloatingActionButton(
                      heroTag: 'specialBtn',
                      backgroundColor: state.specialMeter >= 100 ? Colors.blueAccent : Colors.grey,
                      onPressed: state.specialMeter >= 100 ? () {
                         game.triggerSpecial();
                      } : null,
                      child: const Icon(Icons.local_fire_department),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildJoystick() {
    return GestureDetector(
      onPanUpdate: (details) {
        final delta = details.delta;
        // Basic normalization
        final v = Vector2(delta.dx, delta.dy);
        if (v.length > 0) v.normalize();
        game.updateJoystick(v);
      },
      onPanEnd: (_) {
        game.updateJoystick(Vector2.zero());
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
