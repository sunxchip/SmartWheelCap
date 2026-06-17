import 'package:wheelcap/domain/entities/ble_connection_status.dart';
import 'package:wheelcap/domain/entities/wheel_sensor_data.dart';

abstract class SensorDataSource {
  Stream<WheelSensorData> get dataStream;
  Stream<BleConnectionStatus> get connectionStatusStream;
  void dispose();
}
