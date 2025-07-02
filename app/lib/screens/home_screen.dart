import 'package:flutter/material.dart';
import '../widgets/monitoring_card.dart';
import '../widgets/header_widget.dart';
import '../widgets/animated_background.dart';
import '../services/thingspeak_service.dart';
import '../models/sensor_data.dart';
import 'chart_screen.dart';
import 'dart:async'; // For Timer

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late AnimationController _buttonAnimationController;
  late Animation<double> _cardFadeAnimation;
  late Animation<Offset> _cardSlideAnimation;
  late Animation<double> _buttonScaleAnimation;
  
  // Alert monitoring variables
  Timer? _monitoringTimer;
  bool _isAlertShown = false;
  double _currentMoisture =00.0; // Mock current temperature
  double _currentWaterLevel = 00.0; // Mock current water level
  
  // Alert thresholds
  static const double MOISTURE_THRESHOLD = 15;
  static const double WATER_LEVEL_THRESHOLD = 15;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
    _startMonitoring();
    _checkSensorValues();
  }

  void _initAnimations() {
    _cardAnimationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _buttonAnimationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _cardFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _cardSlideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _cardAnimationController,
            curve: Curves.elasticOut,
          ),
        );

    _buttonScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.bounceOut,
      ),
    );
  }

  void _startAnimations() {
    Future.delayed(Duration(milliseconds: 500), () {
      _cardAnimationController.forward();
    });
    Future.delayed(Duration(milliseconds: 300), () {
      _buttonAnimationController.forward();
    });
  }

  void _startMonitoring() {
    // Start periodic monitoring every 30 seconds
    _monitoringTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _checkSensorValues();
    });
    
    // Initial check after 5 seconds
    Future.delayed(Duration(seconds: 5), () {
      _checkSensorValues();
    });
  }

  Future<void> _checkSensorValues() async {
  try {
    final waterLevelResponse = await ThingSpeakService.getFieldData('1'); // field1 = Water level
    final MoistureResponse = await ThingSpeakService.getFieldData('4'); // field2 = Moisture

    setState(() {
      if (waterLevelResponse.feeds.isNotEmpty) {
        _currentWaterLevel = waterLevelResponse.feeds.last.value;
      }
      if (MoistureResponse.feeds.isNotEmpty) {
        _currentMoisture = MoistureResponse.feeds.last.value;
      }
    });

    // Check thresholds
    bool temperatureAlert = _currentMoisture < MOISTURE_THRESHOLD;
    bool waterLevelAlert = _currentWaterLevel < WATER_LEVEL_THRESHOLD;

    if ((temperatureAlert || waterLevelAlert) && !_isAlertShown) {
      _showAlertNotification(temperatureAlert, waterLevelAlert);
    }

  } catch (e) {
    print('Error fetching sensor data: $e');
  }
}


  void _showAlertNotification(bool temperatureAlert, bool waterLevelAlert) {
    _isAlertShown = true;
    
    String alertMessage = '';
    List<String> alerts = [];
    
    if (temperatureAlert) {
      alerts.add('Mosture is critically low: ${_currentMoisture.toStringAsFixed(1)}%');
      
    }
    if (waterLevelAlert) {

      alerts.add('Water level is critically low: ${_currentWaterLevel.toStringAsFixed(1)}cm');
    }
    
    alertMessage = alerts.join('\n');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Critical Alert!',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Immediate attention required:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  alertMessage,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Detected at: ${DateTime.now().toString().substring(0, 19)}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _isAlertShown = false;
              },
              child: Text(
                'Dismiss',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _buttonAnimationController.dispose();
    _monitoringTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          AnimatedBackground(),

          SafeArea(
            child: Column(
              children: [
                // Enhanced Header Section
                HeaderWidget(),
                // Status indicators
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatusIndicator(
                        'All Systems',
                        _getSystemStatus(),
                        _getSystemStatusColor(),
                        _getSystemStatusIcon(),
                      ),
                      Container(width: 1, height: 30, color: Colors.grey[300]),
                      _buildStatusIndicator(
                        'Last Update',
                        'Now',
                        Colors.blue,
                        Icons.refresh,
                      ),
                      Container(width: 1, height: 30, color: Colors.grey[300]),
                      _buildStatusIndicator(
                        'Sensors',
                        '4 Active',
                        Colors.orange,
                        Icons.sensors,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // Section title
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        'Monitoring Dashboard',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Live',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Enhanced Monitoring Cards Grid
                Expanded(
                  child: AnimatedBuilder(
                    animation: _cardFadeAnimation,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _cardFadeAnimation,
                        child: SlideTransition(
                          position: _cardSlideAnimation,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.0,
                              physics: BouncingScrollPhysics(),
                              children: [
                                MonitoringCard(
                                  title: 'Water Level',
                                  icon: Icons.waves,
                                  color: _currentWaterLevel < WATER_LEVEL_THRESHOLD 
                                      ? Colors.red 
                                      : Color(0xFF2196F3),
                                  unit: 'cm',
                                  fieldNumber: '1',
                                  onTapped: () => _navigateToChart(
                                    context,
                                    'Water Level',
                                    '1',
                                    Color(0xFF2196F3),
                                  ),
                                  delay: 0,
                                ),
                                MonitoringCard(
                                  title: 'Temparature',
                                  icon: Icons.water_drop_outlined,
                                  color: Color(0xFF4CAF50),
                                  unit: '°C',
                                  fieldNumber: '2',
                                  onTapped: () => _navigateToChart(
                                    context,
                                    'Temparature',
                                    '2',
                                    Color(0xFF4CAF50),
                                  ),
                                  delay: 200,
                                ),
                                MonitoringCard(
                                  title: 'Humidity',
                                  icon: Icons.device_thermostat,
                                  color: Color.fromARGB(255, 94, 81, 107),
                                  unit: '%',
                                  fieldNumber: '3',
                                  onTapped: () => _navigateToChart(
                                    context,
                                    'Humidity',
                                    '3',
                                    Color(0xFFFF9800),
                                  ),
                                  delay: 400,
                                ),
                                MonitoringCard(
                                  title: 'Moisture',
                                  icon: Icons.opacity,
                                  color: _currentMoisture > MOISTURE_THRESHOLD 
                                      ? Colors.red 
                                      : Color(0xFFFF9800),
                                  unit: '%',
                                  fieldNumber: '4',
                                  onTapped: () => _navigateToChart(
                                    context,
                                    'Moisture',
                                    '4',
                                    Color(0xFF9C27B0),
                                  ),
                                  delay: 600,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getSystemStatus() {
    bool hasAlert = _currentMoisture > MOISTURE_THRESHOLD || 
                   _currentWaterLevel < WATER_LEVEL_THRESHOLD;
    return hasAlert ? 'Alert' : 'Online';
  }

  Color _getSystemStatusColor() {
    bool hasAlert = _currentMoisture > MOISTURE_THRESHOLD || 
                   _currentWaterLevel < WATER_LEVEL_THRESHOLD;
    return hasAlert ? Colors.red : Colors.green;
  }

  IconData _getSystemStatusIcon() {
    bool hasAlert = _currentMoisture > MOISTURE_THRESHOLD|| 
                   _currentWaterLevel < WATER_LEVEL_THRESHOLD;
    return hasAlert ? Icons.warning : Icons.check_circle;
  }

  Widget _buildStatusIndicator(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _navigateToChart(
    BuildContext context,
    String title,
    String fieldNumber,
    Color color,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ChartScreen(title: title, fieldNumber: fieldNumber, color: color),
      ),
    );
  }

  void _sendAlert(BuildContext context) async {
      String alertDetails = '';
      if (_currentMoisture > MOISTURE_THRESHOLD) {
        alertDetails += 'Temperature Alert: ${_currentMoisture.toStringAsFixed(1)}°C (Threshold: $MOISTURE_THRESHOLD°C)\n';
      }
      if (_currentWaterLevel < WATER_LEVEL_THRESHOLD) {
        alertDetails += 'Water Level Alert: ${_currentWaterLevel.toStringAsFixed(1)}cm (Threshold: $WATER_LEVEL_THRESHOLD cm)\n';
      }
  } 
}