import 'dart:async';

import 'package:flutter/material.dart';

import 'package:wheelcap/core/theme/app_colors.dart';
import 'package:wheelcap/data/datasources/mock_sensor_data_source.dart';
import 'package:wheelcap/data/datasources/sensor_data_source.dart';
import 'package:wheelcap/domain/entities/wheel_sensor_data.dart';
import 'package:wheelcap/presentation/widgets/car_gauge_overlay.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final SensorDataSource _source;
  late final StreamSubscription<WheelSensorData> _sub;

  WheelSensorData _current = WheelSensorData.initial;

  @override
  void initState() {
    super.initState();
    // -------------------------------------------------------------------------
    // Bluetooth 연동 시 MockSensorDataSource → BluetoothSensorDataSource 교체
    // ↓ 이 부분에 Bluetooth stream 데이터를 주입 ↓
    // -------------------------------------------------------------------------
    _source = MockSensorDataSource();
    _sub = _source.dataStream.listen(
      (data) { if (mounted) setState(() => _current = data); },
    );
  }

  @override
  void dispose() {
    _sub.cancel();
    _source.dispose();
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
          child: CarGaugeOverlay(data: _current),
        ),
      ),
    );
  }
}
