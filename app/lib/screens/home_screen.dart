import 'package:flutter/material.dart';
import '../widgets/monitoring_card.dart';
import '../widgets/header_widget.dart';
import '../widgets/animated_background.dart';
import '../services/email_service.dart';
import 'chart_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final String recipientEmail =
      "admin@watermonitoring.com"; // Replace with your email
  late AnimationController _cardAnimationController;
  late AnimationController _buttonAnimationController;
  late Animation<double> _cardFadeAnimation;
  late Animation<Offset> _cardSlideAnimation;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
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

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _buttonAnimationController.dispose();
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

                // Alert Button with animation
                AnimatedBuilder(
                  animation: _buttonScaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _buttonScaleAnimation.value,
                      child: Container(
                        margin: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 15,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.red[400]!, Colors.red[600]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _sendAlert(context),
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 24,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.email_outlined,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Send Emergency Alert',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

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
                        'Online',
                        Colors.green,
                        Icons.check_circle,
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
                                  color: Color(0xFF2196F3),
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
                                  title: 'Humidity',
                                  icon: Icons.water_drop_outlined,
                                  color: Color(0xFF4CAF50),
                                  unit: '%',
                                  fieldNumber: '2',
                                  onTapped: () => _navigateToChart(
                                    context,
                                    'Humidity',
                                    '2',
                                    Color(0xFF4CAF50),
                                  ),
                                  delay: 200,
                                ),
                                MonitoringCard(
                                  title: 'Temperature',
                                  icon: Icons.device_thermostat,
                                  color: Color(0xFFFF9800),
                                  unit: '°C',
                                  fieldNumber: '3',
                                  onTapped: () => _navigateToChart(
                                    context,
                                    'Temperature',
                                    '3',
                                    Color(0xFFFF9800),
                                  ),
                                  delay: 400,
                                ),
                                MonitoringCard(
                                  title: 'Moisture',
                                  icon: Icons.opacity,
                                  color: Color(0xFF9C27B0),
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
    try {
      await EmailService.sendAlertEmail(
        recipientEmail: recipientEmail,
        subject: 'Water Monitoring System Alert',
        body:
            '''
Dear Administrator,

This is an automated alert from the Water Monitoring System.

Please check the current water quality parameters and take necessary action if required.

Timestamp: ${DateTime.now().toString()}

Best regards,
Water Monitoring System
        ''',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email client opened successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
