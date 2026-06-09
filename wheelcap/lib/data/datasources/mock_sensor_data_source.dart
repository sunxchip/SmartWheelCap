import 'dart:async';
import 'dart:math';

import 'package:wheelcap/data/datasources/sensor_data_source.dart';
import 'package:wheelcap/domain/entities/wheel_sensor_data.dart';

/// 목업 데이터
class MockSensorDataSource implements SensorDataSource {
  static const double _min   = 20;
  static const double _max   = 150;
  static const double _delta = 20;
  static const double _alpha = 0.45;

  final _controller = StreamController<WheelSensorData>.broadcast();
  final _rng        = Random();
  Timer? _timer;

  double _tFL = 110, _tFR = 110, _tRL = 120, _tRR = 120;
  double _sFL = 110, _sFR = 110, _sRL = 120, _sRR = 120;

  MockSensorDataSource() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    _tFL = _nudge(_tFL); _tFR = _nudge(_tFR);
    _tRL = _nudge(_tRL); _tRR = _nudge(_tRR);

    _sFL = _ema(_sFL, _tFL); _sFR = _ema(_sFR, _tFR);
    _sRL = _ema(_sRL, _tRL); _sRR = _ema(_sRR, _tRR);

    _controller.add(WheelSensorData(
      frontLeft: _sFL, frontRight: _sFR,
      rearLeft:  _sRL, rearRight:  _sRR,
    ));
  }

  double _nudge(double v) =>
      (v + (_rng.nextDouble() * 2 - 1) * _delta).clamp(_min, _max);

  double _ema(double prev, double next) => prev + _alpha * (next - prev);

  @override
  Stream<WheelSensorData> get dataStream => _controller.stream;

  @override
  void dispose() { _timer?.cancel(); _controller.close(); }
}
