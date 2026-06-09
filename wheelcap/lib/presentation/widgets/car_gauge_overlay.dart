import 'dart:math';

import 'package:flutter/material.dart';

import 'package:wheelcap/domain/entities/wheel_sensor_data.dart';
import 'package:wheelcap/presentation/widgets/wheel_gauge.dart';

/// Positions the four [WheelGauge] widgets precisely at each wheel corner
/// of the car image.
///
/// The car image is rendered with [_carHPad] horizontal padding on both
/// sides. Each gauge's arc ORIGIN (a corner of its 100×100 widget) is
/// placed exactly at the car body edge × the axle height — so the arcs
/// radiate outward from the wheel, not from the screen corner.
///
///   ┌──[carHPad]──┬──── car ────┬──[carHPad]──┐
///   │  FL arcs ←━━┥ FL wheel    │ FR wheel ━━→ FR arcs  │
///   │             │             │             │
///   │  RL arcs ←━━┥ RL wheel    │ RR wheel ━━→ RR arcs  │
///   └─────────────┴─────────────┴─────────────┘
///
/// Tune [_frontAxleFrac] / [_rearAxleFrac] to match your car.png.
/// (fraction of overlay height where each axle sits)
///
class CarGaugeOverlay extends StatelessWidget {
  final WheelSensorData data;
  const CarGaugeOverlay({super.key, required this.data});

  // ── Car image horizontal padding — keep in sync with the Image widget ──────
  static const double _carHPad = 85.0;

  // ── Axle heights as fraction of overlay height ────────────────────────────
  // Adjust these two constants if gauges don't align with your car.png wheels.
  static const double _frontAxleFrac = 0.28;
  static const double _rearAxleFrac  = 0.70;

  static const double _gs = 100.0; // gauge widget size (square)

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      final w = c.maxWidth;
      final h = c.maxHeight;

      // Absolute X of car left / right edge
      final carLeft  = _carHPad;
      final carRight = w - _carHPad;

      // Absolute Y of each axle
      final frontY = h * _frontAxleFrac;
      final rearY  = h * _rearAxleFrac;

      return Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [

          // ── Car image ──────────────────────────────────────────────────────
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: _carHPad),
              child: Image.asset('assets/images/car.png', fit: BoxFit.contain),
            ),
          ),

          // ── Front-Left ─────────────────────────────────────────────────────
          // Arc origin = widget's bottom-right corner = (carLeft, frontY).
          // Arcs fan: π → 3π/2  (left to up, upper-left quadrant).
          Positioned(
            left: carLeft - _gs,
            top:  frontY  - _gs,
            child: WheelGauge(
              distanceCm:     data.frontLeft,
              startAngle:     pi,
              sweepAngle:     pi / 2,
              centerFraction: const Offset(1.0, 1.0),
            ),
          ),

          // ── Front-Right ────────────────────────────────────────────────────
          // Arc origin = widget's bottom-left corner = (carRight, frontY).
          // Arcs fan: 3π/2 → 2π  (up to right, upper-right quadrant).
          Positioned(
            left: carRight,
            top:  frontY - _gs,
            child: WheelGauge(
              distanceCm:     data.frontRight,
              startAngle:     3 * pi / 2,
              sweepAngle:     pi / 2,
              centerFraction: const Offset(0.0, 1.0),
            ),
          ),

          // ── Rear-Left ──────────────────────────────────────────────────────
          // Arc origin = widget's top-right corner = (carLeft, rearY).
          // Arcs fan: π/2 → π  (down to left, lower-left quadrant).
          Positioned(
            left: carLeft - _gs,
            top:  rearY,
            child: WheelGauge(
              distanceCm:     data.rearLeft,
              startAngle:     pi / 2,
              sweepAngle:     pi / 2,
              centerFraction: const Offset(1.0, 0.0),
            ),
          ),

          // ── Rear-Right ─────────────────────────────────────────────────────
          // Arc origin = widget's top-left corner = (carRight, rearY).
          // Arcs fan: 0 → π/2  (right to down, lower-right quadrant).
          Positioned(
            left: carRight,
            top:  rearY,
            child: WheelGauge(
              distanceCm:     data.rearRight,
              startAngle:     0,
              sweepAngle:     pi / 2,
              centerFraction: const Offset(0.0, 0.0),
            ),
          ),
        ],
      );
    });
  }
}
