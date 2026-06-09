import 'package:flutter/material.dart';

abstract class AppColors {
  static const List<Color> backgroundGradient = [
    Color(0xFF0A0E1A),
    Color(0xFF0D1220),
    Color(0xFF111827),
    Color(0xFF0A0F1C),
  ];

  static const Color safe    = Colors.green;
  static const Color caution = Colors.yellow;
  static const Color danger  = Colors.red;

  static Color forDistance(double distCm) {
    if (distCm > 80)  return safe;
    if (distCm >= 40) return caution;
    return danger;
  }
}
