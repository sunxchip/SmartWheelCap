import 'dart:async';

import 'package:wheelcap/data/datasources/sensor_data_source.dart';
import 'package:wheelcap/domain/entities/wheel_sensor_data.dart';

/// TODO: BLE 연동 구현체
///   1. flutter_blue_plus
///   2. DashboardScreen 에서 MockSensorDataSource 대신 이 클래스 교체
///   3. scanAndConnect() 를 호출해 기기를 연결


class BluetoothSensorDataSource implements SensorDataSource {
  final _controller = StreamController<WheelSensorData>.broadcast();

  BluetoothSensorDataSource() {
    // 나중에 활성화
    // scanAndConnect();
  }

  /// BLE 기기 검색 및 연결
  Future<void> scanAndConnect() async {
    // import 'package:flutter_blue_plus/flutter_blue_plus.dart';
    //
    // await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    // FlutterBluePlus.scanResults.listen((results) {
    //   for (final r in results) {
    //     if (r.device.platformName == 'SmartWheelCap') {
    //       FlutterBluePlus.stopScan();
    //       _connectToDevice(r.device);
    //     }
    //   }
    // });
  }

  // void _connectToDevice(BluetoothDevice device) async {
  //   await device.connect();
  //   final services = await device.discoverServices();
  //   for (final service in services) {
  //     for (final char in service.characteristics) {
  //       if (char.properties.notify) {
  //         await char.setNotifyValue(true);
  //         char.onValueReceived.listen((bytes) {
  //           // bytes 파싱 후 스트림에 주입
  //           // 이 부분에 Bluetooth stream 데이터를 주입
  //           // _controller.add(_parseBytes(bytes));
  //         });
  //       }
  //     }
  //   }
  // }

  // WheelSensorData _parseBytes(List<int> bytes) {
  //   // TODO: 아두이노 파싱
  //   // ex: [fl_hi, fl_lo, fr_hi, fr_lo, rl_hi, rl_lo, rr_hi, rr_lo]
  //   return WheelSensorData(
  //     frontLeft:  ((bytes[0] << 8) | bytes[1]).toDouble(),
  //     frontRight: ((bytes[2] << 8) | bytes[3]).toDouble(),
  //     rearLeft:   ((bytes[4] << 8) | bytes[5]).toDouble(),
  //     rearRight:  ((bytes[6] << 8) | bytes[7]).toDouble(),
  //   );
  // }

  @override
  Stream<WheelSensorData> get dataStream => _controller.stream;

  @override
  void dispose() => _controller.close();
}
