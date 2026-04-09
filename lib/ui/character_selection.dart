import 'package:flutter/material.dart';
import '../main.dart';
import '../game/neon_vengeance_game.dart';

class CharacterSelectionScreen extends StatelessWidget {
  const CharacterSelectionScreen({super.key});

  static const _heroes = [
    _HeroData(
      name: 'The Dark Vigilante',
      subtitle: 'Fear Strike',
      type: HeroType.vigilante,
      color: Color(0xFF00E5FF),
      accentColor: Color(0xFF263238),
      spriteAsset: 'assets/images/vigilante_idle.png',
    ),
    _HeroData(
      name: 'The Chaos Jester',
      subtitle: 'Laughing Gas',
      type: HeroType.jester,
      color: Color(0xFFAA00FF),
      accentColor: Color(0xFF1B0033),
      spriteAsset: 'assets/images/jester_idle.png',
    ),
    _HeroData(
      name: 'The Divine Warrior',
      subtitle: 'Amazonian Shock',
      type: HeroType.warrior,
      color: Color(0xFFFFD740),
      accentColor: Color(0xFF3E2723),
      spriteAsset: 'assets/images/warrior_idle.png',
    ),
    _HeroData(
      name: 'The Bolt Speedster',
      subtitle: 'Supersonic Vortex',
      type: HeroType.speedster,
      color: Color(0xFFFF1744),
      accentColor: Color(0xFF3E0000),
      spriteAsset: 'assets/images/speedster_idle.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image – hero group
          Image.asset(
            'assets/images/hero_group.png',
            fit: BoxFit.cover,
          ),
          // Dark gradient overlay for readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.5),
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.7),
                  Colors.black.withValues(alpha: 0.95),
                ],
                stops: const [0.0, 0.3, 0.6, 1.0],
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Title
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFFF00FF), Color(0xFF00FFFF)],
                  ).createShader(bounds),
                  child: const Text(
                    'NEON VENGEANCE',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 6,
                      shadows: [
                        Shadow(color: Color(0xFFFF00FF), blurRadius: 30),
                        Shadow(color: Color(0xFF00FFFF), blurRadius: 60),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'CHOOSE YOUR HERO',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withValues(alpha: 0.7),
                    letterSpacing: 8,
                  ),
                ),
                const Spacer(),
                // Hero cards row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _heroes
                        .map((hero) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: _HeroCard(hero: hero),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroData {
  final String name;
  final String subtitle;
  final HeroType type;
  final Color color;
  final Color accentColor;
  final String spriteAsset;

  const _HeroData({
    required this.name,
    required this.subtitle,
    required this.type,
    required this.color,
    required this.accentColor,
    required this.spriteAsset,
  });
}

class _HeroCard extends StatefulWidget {
  final _HeroData hero;

  const _HeroCard({required this.hero});

  @override
  State<_HeroCard> createState() => _HeroCardState();
}

class _HeroCardState extends State<_HeroCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hero = widget.hero;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => GameScreen(heroType: hero.type)),
          );
        },
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.translationValues(0.0, _isHovered ? -8.0 : 0.0, 0.0),
              child: Container(
                height: 320,
                decoration: BoxDecoration(
                  color: hero.accentColor.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hero.color.withValues(alpha: _isHovered ? 1.0 : _glowAnimation.value),
                    width: _isHovered ? 3 : 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: hero.color.withValues(alpha: _isHovered ? 0.6 : _glowAnimation.value * 0.3),
                      blurRadius: _isHovered ? 25 : 15,
                      spreadRadius: _isHovered ? 3 : 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      // Hero sprite image
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 60),
                          child: Image.asset(
                            hero.spriteAsset,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      // Bottom gradient overlay for text
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 90,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.9),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Hero name and subtitle
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              hero.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(color: hero.color, blurRadius: 10),
                                ],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: hero.color.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: hero.color.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                hero.subtitle,
                                style: TextStyle(
                                  color: hero.color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
