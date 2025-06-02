import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(WaterMonitoringApp());
}

class WaterMonitoringApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water Monitoring System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
