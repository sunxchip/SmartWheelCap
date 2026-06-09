class WheelSensorData {
  final double frontLeft;
  final double frontRight;
  final double rearLeft;
  final double rearRight;

  const WheelSensorData({
    required this.frontLeft,
    required this.frontRight,
    required this.rearLeft,
    required this.rearRight,
  });

  static const WheelSensorData initial = WheelSensorData(
    frontLeft:  150,
    frontRight: 150,
    rearLeft:   150,
    rearRight:  150,
  );

  double get minDistance {
    double m = frontLeft;
    if (frontRight < m) m = frontRight;
    if (rearLeft   < m) m = rearLeft;
    if (rearRight  < m) m = rearRight;
    return m;
  }
}
