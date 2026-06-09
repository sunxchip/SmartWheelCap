import 'package:wheelcap/domain/entities/wheel_sensor_data.dart';

abstract class SensorDataSource {
  Stream<WheelSensorData> get dataStream;
  void dispose();
}
