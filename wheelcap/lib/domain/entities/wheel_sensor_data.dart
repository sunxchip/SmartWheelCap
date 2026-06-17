import 'package:wheelcap/domain/entities/wheel_position.dart';

/// ProxAlert 센서 한 대로부터 들어오는 최신 측정값.
///
/// 차량에는 센서가 하나뿐이라 [activePosition] 코너만 실데이터를 가지며,
/// 나머지 3개 코너는 UI에서 placeholder로 표시된다.
/// [intensity]는 아두이노가 보내는 0~100 원본 값이며, null은 아직 값을
/// 수신하지 못했거나 연결이 끊긴 상태를 의미한다.
class WheelSensorData {
  final WheelPosition activePosition;
  final int? intensity;

  const WheelSensorData({required this.activePosition, this.intensity});

  static const initial = WheelSensorData(activePosition: activeWheelPosition);

  bool get isDanger => intensity == 100;
}
