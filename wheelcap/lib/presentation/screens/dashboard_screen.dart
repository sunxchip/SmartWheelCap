import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import 'package:wheelcap/core/theme/app_colors.dart';
import 'package:wheelcap/data/datasources/bluetooth_sensor_data_source.dart';
import 'package:wheelcap/data/datasources/sensor_data_source.dart';
import 'package:wheelcap/domain/entities/ble_connection_status.dart';
import 'package:wheelcap/domain/entities/wheel_sensor_data.dart';
import 'package:wheelcap/presentation/widgets/car_gauge_overlay.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final SensorDataSource _source;
  late final StreamSubscription<WheelSensorData> _dataSub;
  late final StreamSubscription<BleConnectionStatus> _statusSub;
  late final AnimationController _dangerPulseCtrl;

  WheelSensorData _current = WheelSensorData.initial;
  BleConnectionStatus _status = BleConnectionStatus.scanning;
  bool _isVibrating = false;

  @override
  void initState() {
    super.initState();
    _dangerPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _source = BluetoothSensorDataSource();
    _dataSub = _source.dataStream.listen(_handleData);
    _statusSub = _source.connectionStatusStream.listen((status) {
      if (mounted) setState(() => _status = status);
    });
  }

  void _handleData(WheelSensorData data) {
    if (!mounted) return;
    setState(() => _current = data);
    _updateDangerEffects(data);
  }

  /// intensity 100 진입 시 연속 진동 시작, 벗어나면(연결 끊김 포함) 정지.
  void _updateDangerEffects(WheelSensorData data) {
    if (data.isDanger && !_isVibrating) {
      _isVibrating = true;
      Vibration.hasVibrator().then((hasVibrator) {
        if (hasVibrator && _isVibrating) {
          Vibration.vibrate(pattern: [0, 700, 250], repeat: 0);
        }
      });
    } else if (!data.isDanger && _isVibrating) {
      _isVibrating = false;
      Vibration.cancel();
    }
  }

  @override
  void dispose() {
    _dataSub.cancel();
    _statusSub.cancel();
    _source.dispose();
    _dangerPulseCtrl.dispose();
    if (_isVibrating) Vibration.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.backgroundGradient,
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              CarGaugeOverlay(data: _current),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _ConnectionBanner(status: _status),
              ),
              if (_current.isDanger) _DangerOverlay(pulse: _dangerPulseCtrl),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectionBanner extends StatelessWidget {
  final BleConnectionStatus status;
  const _ConnectionBanner({required this.status});

  String get _label {
    switch (status) {
      case BleConnectionStatus.scanning:
        return 'ProxAlert 검색 중…';
      case BleConnectionStatus.connecting:
        return '연결 중…';
      case BleConnectionStatus.connected:
        return 'ProxAlert 연결됨';
      case BleConnectionStatus.disconnected:
        return '연결 끊김 · 재연결 시도 중…';
    }
  }

  Color get _dotColor {
    switch (status) {
      case BleConnectionStatus.connected:
        return AppColors.safe;
      case BleConnectionStatus.disconnected:
        return AppColors.danger;
      case BleConnectionStatus.scanning:
      case BleConnectionStatus.connecting:
        return AppColors.caution;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: _dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            _label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DangerOverlay extends StatelessWidget {
  final Animation<double> pulse;
  const _DangerOverlay({required this.pulse});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: pulse,
          builder: (_, __) => Container(
            color: AppColors.danger.withValues(alpha: 0.15 + pulse.value * 0.35),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 64,
                ),
                const SizedBox(height: 12),
                Text(
                  '위험! 장애물 근접',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    shadows: [Shadow(color: AppColors.danger, blurRadius: 12)],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
