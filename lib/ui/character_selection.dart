import 'package:flutter/material.dart';
import '../main.dart';
import '../game/neon_vengeance_game.dart';

class CharacterSelectionScreen extends StatelessWidget {
  const CharacterSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('HERO SELECT', style: TextStyle(fontSize: 40, color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSlot(context, 'The Dark Vigilante', HeroType.vigilante, Colors.grey),
                const SizedBox(width: 20),
                _buildSlot(context, 'The Chaos Jester', HeroType.jester, Colors.purple),
                const SizedBox(width: 20),
                _buildSlot(context, 'The Divine Warrior', HeroType.warrior, Colors.orange), 
                const SizedBox(width: 20),
                _buildSlot(context, 'The Bolt Speedster', HeroType.speedster, Colors.red), 
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSlot(BuildContext context, String name, HeroType type, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => GameScreen(heroType: type)));
      },
      child: Container(
        width: 150,
        height: 200,
        decoration: BoxDecoration(
          color: color.withAlpha(76),
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(name, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
