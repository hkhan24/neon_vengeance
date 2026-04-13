import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame/components.dart';
import '../state/game_state.dart';
import '../game/neon_vengeance_game.dart';
import 'character_selection.dart';

class GameOverlay extends ConsumerStatefulWidget {
  final NeonVengeanceGame game;

  const GameOverlay({super.key, required this.game});

  @override
  ConsumerState<GameOverlay> createState() => _GameOverlayState();
}

class _GameOverlayState extends ConsumerState<GameOverlay> {
  bool _isPaused = false;

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        widget.game.pauseEngine();
      } else {
        widget.game.resumeEngine();
      }
    });
  }

  void _resumeGame() {
    setState(() {
      _isPaused = false;
      widget.game.resumeEngine();
    });
  }

  void _quitToMenu() {
    widget.game.resumeEngine();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CharacterSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameStateProvider);

    return Stack(
      children: [
        // Main HUD
        SafeArea(
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
                          color: Colors.red.withValues(alpha: 0.3),
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
                          color: Colors.blue.withValues(alpha: 0.3),
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 200 * (state.specialMeter.toDouble() / 100),
                            height: 10,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                    // Score + Pause button
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('SCORE: ${state.score}', style: const TextStyle(color: Colors.yellow, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        _buildPauseButton(),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                // Controls (hidden when paused)
                if (!_isPaused)
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
                              widget.game.tapAttack();
                            },
                            child: const Icon(Icons.flash_on),
                          ),
                          const SizedBox(width: 16),
                          FloatingActionButton(
                            heroTag: 'specialBtn',
                            backgroundColor: state.specialMeter >= 100 ? Colors.blueAccent : Colors.grey,
                            onPressed: state.specialMeter >= 100 ? () {
                               widget.game.triggerSpecial();
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
        ),
        // Pause menu overlay
        if (_isPaused) _buildPauseMenu(),
      ],
    );
  }

  Widget _buildPauseButton() {
    return GestureDetector(
      onTap: _togglePause,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
        ),
        child: Icon(
          _isPaused ? Icons.play_arrow : Icons.pause,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildPauseMenu() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00FFFF).withValues(alpha: 0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FFFF).withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'PAUSED',
                style: TextStyle(
                  color: Color(0xFF00FFFF),
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6,
                  shadows: [
                    Shadow(color: Color(0xFF00FFFF), blurRadius: 20),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildMenuButton('RESUME', Icons.play_arrow, const Color(0xFF00E676), _resumeGame),
              const SizedBox(height: 12),
              _buildMenuButton('QUIT TO MENU', Icons.exit_to_app, const Color(0xFFFF1744), _quitToMenu),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoystick() {
    return GestureDetector(
      onPanUpdate: (details) {
        // Center of the 120x120 Container
        const center = Offset(60, 60);
        final delta = details.localPosition - center;
        
        final v = Vector2(delta.dx, delta.dy);
        // Small deadzone so resting the thumb perfectly centered doesn't jitter
        if (v.length > 15) {
          v.normalize();
        } else {
          v.setZero();
        }
        widget.game.updateJoystick(v);
      },
      onPanEnd: (_) {
        widget.game.updateJoystick(Vector2.zero());
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
