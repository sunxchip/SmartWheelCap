import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Four concentric arc bands — wheel-proximity sensor style.
///
/// No glow, no blur. Clean rounded stroke caps on every band.
/// Origin ([centerFraction]) sits at the wheel corner of the widget.
///
///  FL → centerFraction (1, 1)  sweep π   → 3π/2   upper-left
///  FR → centerFraction (0, 1)  sweep 3π/2→ 2π    upper-right
///  RL → centerFraction (1, 0)  sweep π/2 → π     lower-left
///  RR → centerFraction (0, 0)  sweep 0   → π/2   lower-right
class WheelArcPainter extends CustomPainter {
  final double distanceCm;
  final double startAngle;
  final double sweepAngle;
  final Offset centerFraction;

  // Outer → inner
  static const List<double> _radii      = [70, 52, 34, 16];
  static const List<double> _thresholds = [140, 100, 65, 35];
  static const List<Color>  _colors = [
    Color(0xFF43A047), // green  — outermost / safe
    Color(0xFFFFD600), // yellow
    Color(0xFFFF6F00), // orange
    Color(0xFFE53935), // red    — innermost / danger
  ];

  static const double _sw     = 14.0; // stroke width
  static const double _labelR = 82.0; // label radius (outside outermost band)

  const WheelArcPainter({
    required this.distanceCm,
    required this.startAngle,
    required this.sweepAngle,
    required this.centerFraction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(
      centerFraction.dx * size.width,
      centerFraction.dy * size.height,
    );

    // Draw outer → inner so inner arcs render on top
    for (int i = 0; i < _radii.length; i++) {
      final active = distanceCm <= _thresholds[i];
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: _radii[i]),
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..style       = PaintingStyle.stroke
          ..strokeWidth = _sw
          ..strokeCap   = StrokeCap.butt
          ..color       = active ? _colors[i] : _colors[i].withOpacity(0.10),
      );
    }

    _paintLabel(canvas, c);
  }

  void _paintLabel(Canvas canvas, Offset c) {
    final mid = startAngle + sweepAngle / 2;
    final pos = Offset(
      c.dx + _labelR * cos(mid),
      c.dy + _labelR * sin(mid),
    );

    final tp = TextPainter(
      textDirection: ui.TextDirection.ltr,
      text: TextSpan(children: [
        TextSpan(
          text: '${distanceCm.toInt()}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1.0,
          ),
        ),
        TextSpan(
          text: 'cm',
          style: TextStyle(
            color: Colors.white.withOpacity(0.45),
            fontSize: 9,
          ),
        ),
      ]),
    )..layout();

    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(WheelArcPainter old) => old.distanceCm != distanceCm;
}
