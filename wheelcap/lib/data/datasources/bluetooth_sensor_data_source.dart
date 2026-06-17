import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:wheelcap/data/datasources/sensor_data_source.dart';
import 'package:wheelcap/domain/entities/ble_connection_status.dart';
import 'package:wheelcap/domain/entities/wheel_position.dart';
import 'package:wheelcap/domain/entities/wheel_sensor_data.dart';

/// ProxAlert(ESP32-C3) 펌웨어와 BLE로 통신하는 실제 데이터 소스.
///
/// 디바이스 이름 "ProxAlert"를 스캔 → 연결 → 서비스/특성 탐색 → notify 구독
/// 순서로 진행하며, 연결이 끊기면 자동으로 재스캔을 시도한다.
class BluetoothSensorDataSource implements SensorDataSource {
  static final Guid _serviceUuid = Guid('12345678-1234-1234-1234-1234567890ab');
  static final Guid _characteristicUuid = Guid('12345678-1234-1234-1234-1234567890ac');
  static const String _deviceName = 'ProxAlert';

  static const Duration _scanTimeout = Duration(seconds: 8);
  static const Duration _connectTimeout = Duration(seconds: 10);
  static const Duration _reconnectDelay = Duration(seconds: 2);

  final _dataController = StreamController<WheelSensorData>.broadcast();
  final _statusController = StreamController<BleConnectionStatus>.broadcast();

  StreamSubscription<BluetoothConnectionState>? _connectionSub;
  StreamSubscription<List<int>>? _valueSub;
  StreamSubscription<BluetoothAdapterState>? _adapterSub;

  BluetoothDevice? _device;
  bool _disposed = false;
  bool _busy = false;

  BluetoothSensorDataSource() {
    _adapterSub = FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.on) {
        _scanAndConnect();
      }
    });

    // [임시 디버그] 스캔되는 모든 기기를 콘솔에 출력해 매칭 실패 원인을 확인한다.
    // 원인 파악 후 제거할 것.
    FlutterBluePlus.onScanResults.listen((results) {
      for (final r in results) {
        debugPrint(
          '[ProxAlert][scan] advName="${r.advertisementData.advName}" '
          'platformName="${r.device.platformName}" '
          'services=${r.advertisementData.serviceUuids} '
          'rssi=${r.rssi}',
        );
      }
    });
  }

  Future<void> _scanAndConnect() async {
    if (_disposed || _busy) return;
    _busy = true;
    _emitStatus(BleConnectionStatus.scanning);

    try {
      // [임시 디버그] 네이티브 스캔 필터(withServices/withNames)를 빼고
      // 무필터로 스캔해, 주변에 광고가 잡히는지 / ProxAlert가 보이는지 확인.
      // 원인 파악 후 필터를 다시 추가할 것.
      await FlutterBluePlus.startScan(
        timeout: _scanTimeout,
      );

      // 광고 패킷(31바이트 제한)에 128bit 서비스 UUID + 기기 이름을 모두
      // 담으면 용량을 초과해 펌웨어가 이름을 잘라내거나 빼는 경우가 있다.
      // 그래서 이름 일치만으로 판단하지 않고, addServiceUUID()로 펌웨어가
      // 보장하는 서비스 UUID 매칭을 1차 기준으로 삼는다.
      final result = await FlutterBluePlus.onScanResults
          .expand((results) => results)
          .firstWhere((r) =>
              r.advertisementData.serviceUuids.contains(_serviceUuid) ||
              r.advertisementData.advName == _deviceName ||
              r.device.platformName == _deviceName)
          .timeout(_scanTimeout);

      await FlutterBluePlus.stopScan();
      await _connect(result.device);
    } catch (e) {
      debugPrint('[ProxAlert] scan failed: $e');
      await FlutterBluePlus.stopScan();
      _busy = false;
      _scheduleReconnect();
    }
  }

  Future<void> _connect(BluetoothDevice device) async {
    _device = device;
    _emitStatus(BleConnectionStatus.connecting);

    try {
      // 비영리/개인 프로젝트 용도. 상업적으로 배포할 경우
      // License.commercial 라이선스 구매가 필요하다.
      await device.connect(license: License.nonprofit, timeout: _connectTimeout);

      final services = await device.discoverServices();
      final service = services.firstWhere((s) => s.uuid == _serviceUuid);
      final characteristic = service.characteristics.firstWhere((c) => c.uuid == _characteristicUuid);

      await characteristic.setNotifyValue(true);

      _valueSub?.cancel();
      _valueSub = characteristic.lastValueStream.listen((bytes) {
        if (bytes.isEmpty) return;
        _emitIntensity(bytes[0].clamp(0, 100));
      });

      // 연결 성공 *이후*에 구독해야 스트림의 "현재 상태 재방출" 동작 때문에
      // 가짜 disconnected 이벤트가 즉시 발생하는 것을 피할 수 있다.
      _connectionSub?.cancel();
      _connectionSub = device.connectionState
          .where((s) => s == BluetoothConnectionState.disconnected)
          .listen((_) => _handleUnexpectedDisconnect());

      _busy = false;
      _emitStatus(BleConnectionStatus.connected);
    } catch (e) {
      debugPrint('[ProxAlert] connect failed: $e');
      _busy = false;
      await device.disconnect();
      _scheduleReconnect();
    }
  }

  void _handleUnexpectedDisconnect() {
    _connectionSub?.cancel();
    _connectionSub = null;
    _valueSub?.cancel();
    _valueSub = null;

    if (_disposed) return;
    _emitStatus(BleConnectionStatus.disconnected);
    _emitIntensity(null);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    Future.delayed(_reconnectDelay, _scanAndConnect);
  }

  void _emitIntensity(int? intensity) {
    if (_disposed) return;
    _dataController.add(WheelSensorData(activePosition: activeWheelPosition, intensity: intensity));
  }

  void _emitStatus(BleConnectionStatus status) {
    if (_disposed) return;
    _statusController.add(status);
  }

  @override
  Stream<WheelSensorData> get dataStream => _dataController.stream;

  @override
  Stream<BleConnectionStatus> get connectionStatusStream => _statusController.stream;

  @override
  void dispose() {
    _disposed = true;
    _adapterSub?.cancel();
    _connectionSub?.cancel();
    _valueSub?.cancel();
    FlutterBluePlus.stopScan();
    _device?.disconnect();
    _dataController.close();
    _statusController.close();
  }
}
