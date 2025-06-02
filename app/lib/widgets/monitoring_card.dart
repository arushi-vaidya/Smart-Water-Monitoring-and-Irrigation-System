import 'package:flutter/material.dart';
import '../services/thingspeak_service.dart';

class MonitoringCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String unit;
  final String fieldNumber;
  final VoidCallback onTapped;
  final int delay;

  const MonitoringCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.unit,
    required this.fieldNumber,
    required this.onTapped,
    this.delay = 0,
  }) : super(key: key);

  @override
  _MonitoringCardState createState() => _MonitoringCardState();
}

class _MonitoringCardState extends State<MonitoringCard> {
  String currentValue = '--';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLatestValue();
  }

  Future<void> _loadLatestValue() async {
    try {
      final response = await ThingSpeakService.getFieldData(
        widget.fieldNumber,
        results: 1,
      );
      if (response.feeds.isNotEmpty) {
        setState(() {
          currentValue = response.feeds.last.value.toStringAsFixed(1);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        currentValue = 'Error';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTapped,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [widget.color.withOpacity(0.8), widget.color],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.icon, color: Colors.white, size: 24),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white70,
                    size: 16,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      isLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              currentValue,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      SizedBox(width: 4),
                      Text(
                        widget.unit,
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
