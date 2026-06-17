import 'package:flutter/material.dart';

import 'package:wheelcap/presentation/widgets/arc_gauge_painter.dart';

class WheelGauge extends StatefulWidget {
  /// ProxAlert intensity (0~100). null = this corner has no live sensor.
  final int? intensity;
  final double startAngle;
  final double sweepAngle;
  final Offset centerFraction;

  const WheelGauge({
    super.key,
    required this.intensity,
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
    final initial = widget.intensity?.toDouble() ?? 0.0;
    _anim = Tween(begin: initial, end: initial)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(WheelGauge old) {
    super.didUpdateWidget(old);
    final next = widget.intensity;
    if (next == null || old.intensity == next) return;

    final from = old.intensity?.toDouble() ?? next.toDouble();
    _anim = Tween(begin: from, end: next.toDouble())
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl..reset()..forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (widget.intensity == null) {
      return CustomPaint(
        size: const Size(_size, _size),
        painter: WheelArcPainter(
          intensity:      null,
          startAngle:     widget.startAngle,
          sweepAngle:     widget.sweepAngle,
          centerFraction: widget.centerFraction,
        ),
      );
    }
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => CustomPaint(
        size: const Size(_size, _size),
        painter: WheelArcPainter(
          intensity:      _anim.value,
          startAngle:     widget.startAngle,
          sweepAngle:     widget.sweepAngle,
          centerFraction: widget.centerFraction,
        ),
      ),
    );
  }
}
