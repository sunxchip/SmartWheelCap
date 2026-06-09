import 'package:flutter/material.dart';

import 'package:wheelcap/presentation/screens/dashboard_screen.dart';

class WheelCapApp extends StatelessWidget {
  const WheelCapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartWheelCap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: const ColorScheme.dark(),
      ),
      home: const DashboardScreen(),
    );
  }
}
