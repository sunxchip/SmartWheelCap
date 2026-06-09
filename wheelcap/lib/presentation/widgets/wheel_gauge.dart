import 'package:flutter/material.dart';

import 'package:wheelcap/presentation/widgets/arc_gauge_painter.dart';

class WheelGauge extends StatefulWidget {
  final double distanceCm;
  final double startAngle;
  final double sweepAngle;
  final Offset centerFraction;

  const WheelGauge({
    super.key,
    required this.distanceCm,
    required this.startAngle,
    required this.sweepAngle,
    required this.centerFraction,
  });

  @override
  State<WheelGauge> createState() => _WheelGaugeState();
}

class _WheelGaugeState extends State<WheelGauge>
    with SingleTickerProviderStateMixin {
  static const double _size = 100.0;

  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _anim = Tween(begin: widget.distanceCm, end: widget.distanceCm)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(WheelGauge old) {
    super.didUpdateWidget(old);
    if (old.distanceCm != widget.distanceCm) {
      final from = _anim.value;
      _anim = Tween(begin: from, end: widget.distanceCm)
          .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
      _ctrl..reset()..forward();
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => CustomPaint(
        size: const Size(_size, _size),
        painter: WheelArcPainter(
          distanceCm:     _anim.value,
          startAngle:     widget.startAngle,
          sweepAngle:     widget.sweepAngle,
          centerFraction: widget.centerFraction,
        ),
      ),
    );
  }
}
