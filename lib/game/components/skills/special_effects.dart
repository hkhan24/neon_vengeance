import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import '../../neon_vengeance_game.dart';

// ─────────────────────────────────────────────────────────
//  BASE CLASS
// ─────────────────────────────────────────────────────────

/// Base class for all full-screen special-ability visual effects.
abstract class SpecialEffect extends PositionComponent
    with HasGameReference<NeonVengeanceGame> {
  final double duration;
  double elapsed = 0;

  SpecialEffect({required Vector2 origin, this.duration = 1.5})
      : super(position: origin, anchor: Anchor.center);

  /// 0 → 1 progress through the effect lifetime.
  double get progress => (elapsed / duration).clamp(0.0, 1.0);

  /// Ease-out opacity so it fades smoothly at the end.
  double get opacity => (1.0 - progress).clamp(0.0, 1.0);

  @override
  void update(double dt) {
    super.update(dt);
    elapsed += dt;
    if (elapsed >= duration) {
      removeFromParent();
    }
  }
}

// ─────────────────────────────────────────────────────────
//  VIGILANTE – Fear Strike
//  Dark purple/black expanding shockwave rings + bat shapes
// ─────────────────────────────────────────────────────────

class FearStrikeEffect extends SpecialEffect {
  FearStrikeEffect({required super.origin}) : super(duration: 1.6);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final maxRadius = game.size.x * 0.6;

    // Multiple expanding rings at staggered delays
    for (int i = 0; i < 4; i++) {
      final ringProgress = (progress - i * 0.08).clamp(0.0, 1.0);
      if (ringProgress <= 0) continue;

      final radius = maxRadius * ringProgress;
      final ringOpacity = (1.0 - ringProgress) * opacity;

      // Dark purple shockwave ring
      final paint = Paint()
        ..color = Color.fromRGBO(120, 0, 200, ringOpacity * 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (12.0 - ringProgress * 8).clamp(2.0, 12.0)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset.zero, radius, paint);

      // Inner glow
      final glowPaint = Paint()
        ..color = Color.fromRGBO(80, 0, 160, ringOpacity * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      canvas.drawCircle(Offset.zero, radius * 0.9, glowPaint);
    }

    // Bat silhouettes flying outward
    final batCount = 8;
    for (int i = 0; i < batCount; i++) {
      final angle = (i / batCount) * 2 * pi + progress * 1.5;
      final dist = maxRadius * progress * 0.8;
      final bx = cos(angle) * dist;
      final by = sin(angle) * dist - progress * 30;
      final batOpacity = opacity * (1.0 - progress * 0.5);

      final batPaint = Paint()
        ..color = Color.fromRGBO(40, 0, 60, batOpacity * 0.9);

      // Simple bat wing shape
      final batSize = 18.0 - progress * 8;
      final path = Path()
        ..moveTo(bx, by)
        ..quadraticBezierTo(bx - batSize, by - batSize, bx - batSize * 1.5, by)
        ..quadraticBezierTo(bx - batSize * 0.5, by + batSize * 0.3, bx, by + batSize * 0.3)
        ..quadraticBezierTo(bx + batSize * 0.5, by + batSize * 0.3, bx + batSize * 1.5, by)
        ..quadraticBezierTo(bx + batSize, by - batSize, bx, by)
        ..close();
      canvas.drawPath(path, batPaint);
    }

    // Central dark flash
    if (progress < 0.3) {
      final flashOpacity = (1.0 - progress / 0.3) * 0.5;
      final flashPaint = Paint()
        ..color = Color.fromRGBO(20, 0, 40, flashOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
      canvas.drawCircle(Offset.zero, 80, flashPaint);
    }
  }
}

// ─────────────────────────────────────────────────────────
//  JESTER – Laughing Gas
//  Toxic green swirling gas cloud with particles
// ─────────────────────────────────────────────────────────

class LaughingGasEffect extends SpecialEffect {
  final Random _rng = Random(42);
  late final List<_GasParticle> _particles;

  LaughingGasEffect({required super.origin}) : super(duration: 1.8) {
    _particles = List.generate(50, (i) => _GasParticle(_rng));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final maxRadius = game.size.x * 0.55;

    // Expanding toxic cloud layers
    for (int i = 0; i < 5; i++) {
      final layerProgress = (progress - i * 0.04).clamp(0.0, 1.0);
      if (layerProgress <= 0) continue;

      final radius = maxRadius * layerProgress * (0.6 + i * 0.1);
      final layerOpacity = (1.0 - layerProgress) * opacity * 0.4;

      final paint = Paint()
        ..color = Color.fromRGBO(0, 220, 60, layerOpacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 30.0 + i * 10);
      canvas.drawCircle(Offset.zero, radius, paint);
    }

    // Swirling gas particles
    for (final p in _particles) {
      final pProgress = (progress - p.delay).clamp(0.0, 1.0);
      if (pProgress <= 0) continue;

      final angle = p.baseAngle + pProgress * p.spinSpeed;
      final dist = p.baseDist * pProgress * maxRadius;
      final px = cos(angle) * dist + sin(elapsed * 3 + p.wobble) * 15;
      final py = sin(angle) * dist + cos(elapsed * 2 + p.wobble) * 10;
      final pOpacity = opacity * (1.0 - pProgress) * p.alpha;

      // Green particle blob
      final paint = Paint()
        ..color = Color.fromRGBO(p.r, p.g, p.b, pOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(px, py), p.size * (1 + pProgress), paint);
    }

    // Neon green flash at center on activation
    if (progress < 0.2) {
      final flashOpacity = (1.0 - progress / 0.2) * 0.6;
      final flashPaint = Paint()
        ..color = Color.fromRGBO(0, 255, 80, flashOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);
      canvas.drawCircle(Offset.zero, 100, flashPaint);
    }
  }
}

class _GasParticle {
  final double baseAngle;
  final double baseDist;
  final double spinSpeed;
  final double size;
  final double delay;
  final double alpha;
  final double wobble;
  final int r, g, b;

  _GasParticle(Random rng)
      : baseAngle = rng.nextDouble() * 2 * pi,
        baseDist = 0.3 + rng.nextDouble() * 0.7,
        spinSpeed = 1.5 + rng.nextDouble() * 3.0,
        size = 4 + rng.nextDouble() * 10,
        delay = rng.nextDouble() * 0.15,
        alpha = 0.4 + rng.nextDouble() * 0.6,
        wobble = rng.nextDouble() * 6.28,
        r = rng.nextInt(60),
        g = 160 + rng.nextInt(96),
        b = rng.nextInt(80);
}

// ─────────────────────────────────────────────────────────
//  WARRIOR – Amazonian Shock
//  Golden ground-slam impact rings + radial lightning bolts
// ─────────────────────────────────────────────────────────

class AmazonianShockEffect extends SpecialEffect {
  final Random _rng = Random(7);
  late final List<_LightningBolt> _bolts;

  AmazonianShockEffect({required super.origin}) : super(duration: 1.5) {
    _bolts = List.generate(12, (i) => _LightningBolt(_rng, i / 12));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final maxRadius = game.size.x * 0.6;

    // Bright initial flash
    if (progress < 0.15) {
      final flashOpacity = (1.0 - progress / 0.15) * 0.8;
      final flashPaint = Paint()
        ..color = Color.fromRGBO(255, 220, 80, flashOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
      canvas.drawCircle(Offset.zero, 120, flashPaint);
    }

    // Expanding golden impact rings
    for (int i = 0; i < 3; i++) {
      final ringProgress = (progress - i * 0.1).clamp(0.0, 1.0);
      if (ringProgress <= 0) continue;

      final radius = maxRadius * ringProgress;
      final ringOpacity = (1.0 - ringProgress) * opacity;

      // Outer golden ring
      final paint = Paint()
        ..color = Color.fromRGBO(255, 200, 50, ringOpacity * 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (15.0 - ringProgress * 10).clamp(2.0, 15.0)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset.zero, radius, paint);

      // Inner warm glow
      final glowPaint = Paint()
        ..color = Color.fromRGBO(255, 150, 0, ringOpacity * 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
      canvas.drawCircle(Offset.zero, radius * 0.85, glowPaint);
    }

    // Radial lightning bolts
    for (final bolt in _bolts) {
      final boltProgress = (progress - bolt.delay).clamp(0.0, 1.0);
      if (boltProgress <= 0 || boltProgress >= 0.7) continue;

      final boltOpacity = opacity * (1.0 - boltProgress / 0.7);
      final boltLength = maxRadius * 0.9 * boltProgress;

      final paint = Paint()
        ..color = Color.fromRGBO(255, 230, 80, boltOpacity * 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      final glowPaint = Paint()
        ..color = Color.fromRGBO(255, 200, 0, boltOpacity * 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      // Draw jagged lightning path
      final path = Path();
      path.moveTo(0, 0);
      final segments = 8;
      for (int s = 1; s <= segments; s++) {
        final t = s / segments;
        final dist = boltLength * t;
        final jitter = bolt.jitters[s - 1] * 20 * (1 - t * 0.5);
        final baseAngle = bolt.angle;
        final px = cos(baseAngle) * dist + cos(baseAngle + pi / 2) * jitter;
        final py = sin(baseAngle) * dist + sin(baseAngle + pi / 2) * jitter;
        path.lineTo(px, py);
      }

      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, paint);
    }

    // Ground crack lines radiating outward
    if (progress > 0.1 && progress < 0.8) {
      final crackOpacity = opacity * (1.0 - (progress - 0.1) / 0.7) * 0.6;
      final crackPaint = Paint()
        ..color = Color.fromRGBO(255, 180, 0, crackOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      for (int i = 0; i < 16; i++) {
        final angle = (i / 16) * 2 * pi;
        final length = maxRadius * 0.5 * progress;
        canvas.drawLine(
          Offset.zero,
          Offset(cos(angle) * length, sin(angle) * length),
          crackPaint,
        );
      }
    }
  }
}

class _LightningBolt {
  final double angle;
  final double delay;
  final List<double> jitters;

  _LightningBolt(Random rng, double baseAngleFraction)
      : angle = baseAngleFraction * 2 * pi + (rng.nextDouble() - 0.5) * 0.3,
        delay = rng.nextDouble() * 0.1,
        jitters = List.generate(8, (_) => (rng.nextDouble() - 0.5) * 2);
}

// ─────────────────────────────────────────────────────────
//  SPEEDSTER – Supersonic Vortex
//  Electric blue/yellow spiral vortex with lightning arcs
// ─────────────────────────────────────────────────────────

class SupersonicVortexEffect extends SpecialEffect {
  SupersonicVortexEffect({required super.origin}) : super(duration: 1.6);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final maxRadius = game.size.x * 0.55;

    // Vortex spiral arms
    for (int arm = 0; arm < 3; arm++) {
      final armOffset = (arm / 3) * 2 * pi;

      final paint = Paint()
        ..color = Color.fromRGBO(80, 180, 255, opacity * 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      final glowPaint = Paint()
        ..color = Color.fromRGBO(100, 200, 255, opacity * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      final path = Path();
      bool started = false;
      for (int s = 0; s < 60; s++) {
        final t = s / 60.0;
        // Spiral that expands then contracts
        final spiralPhase = progress * 8 + armOffset;
        final r = maxRadius * t * (progress < 0.7 ? progress / 0.7 : 1.0 - (progress - 0.7) / 0.3);
        final angle = spiralPhase + t * 4 * pi;
        final px = cos(angle) * r;
        final py = sin(angle) * r;

        if (!started) {
          path.moveTo(px, py);
          started = true;
        } else {
          path.lineTo(px, py);
        }
      }
      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, paint);
    }

    // Electric arcs jumping around the vortex
    final arcCount = 6;
    for (int i = 0; i < arcCount; i++) {
      final arcPhase = elapsed * 10 + i * (2 * pi / arcCount);
      final arcRadius = maxRadius * 0.3 * progress;
      final ax = cos(arcPhase) * arcRadius;
      final ay = sin(arcPhase) * arcRadius;

      // Random-ish arc endpoint
      final ax2 = cos(arcPhase + 0.8) * arcRadius * 1.3;
      final ay2 = sin(arcPhase + 0.8) * arcRadius * 1.3;

      final arcPaint = Paint()
        ..color = Color.fromRGBO(255, 255, 100, opacity * 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawLine(Offset(ax, ay), Offset(ax2, ay2), arcPaint);

      // Small spark dot
      final sparkPaint = Paint()
        ..color = Color.fromRGBO(255, 255, 200, opacity * 0.9)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawCircle(Offset(ax2, ay2), 4, sparkPaint);
    }

    // Central energy core
    final corePulse = 0.7 + sin(elapsed * 15) * 0.3;
    final coreOpacity = opacity * corePulse;
    final corePaint = Paint()
      ..color = Color.fromRGBO(150, 220, 255, coreOpacity * 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(Offset.zero, 30 * progress.clamp(0, 0.5) * 2, corePaint);

    // Speed lines radiating inward (suction effect)
    if (progress > 0.1) {
      for (int i = 0; i < 20; i++) {
        final angle = (i / 20) * 2 * pi + elapsed * 3;
        final outerR = maxRadius * (0.8 - progress * 0.3);
        final innerR = maxRadius * 0.15 * progress;
        final lineOpacity = opacity * 0.3 * (1.0 - progress);

        final linePaint = Paint()
          ..color = Color.fromRGBO(180, 220, 255, lineOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

        canvas.drawLine(
          Offset(cos(angle) * outerR, sin(angle) * outerR),
          Offset(cos(angle) * innerR, sin(angle) * innerR),
          linePaint,
        );
      }
    }
  }
}
