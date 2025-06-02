import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/thingspeak_service.dart';
import '../models/sensor_data.dart';

class ChartScreen extends StatefulWidget {
  final String title;
  final String fieldNumber;
  final Color color;

  ChartScreen({
    required this.title,
    required this.fieldNumber,
    required this.color,
  });

  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  List<SensorData> data = [];
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
        error = '';
      });

      final response = await ThingSpeakService.getFieldData(widget.fieldNumber);
      setState(() {
        data = response.feeds;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: widget.color,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [IconButton(icon: Icon(Icons.refresh), onPressed: _loadData)],
      ),
      body: Column(
        children: [
          // Header with current value
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Current Reading',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  data.isNotEmpty
                      ? '${data.last.value.toStringAsFixed(1)}'
                      : '--',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getUnit(),
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              ],
            ),
          ),

          // Chart Section
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: _buildContent(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: widget.color),
            SizedBox(height: 16),
            Text('Loading data...'),
          ],
        ),
      );
    }

    if (error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Error loading data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: Text('Retry')),
          ],
        ),
      );
    }

    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timeline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No data available',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Take only the last 20 data points for better readability
    final displayData = data.length > 20
        ? data.sublist(data.length - 20)
        : data;
    final minValue = displayData
        .map((e) => e.value)
        .reduce((a, b) => a < b ? a : b);
    final maxValue = displayData
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;
    final padding = range * 0.1; // 10% padding

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Historical Data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Last ${displayData.length} readings',
                style: TextStyle(
                  color: widget.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Expanded(
          child: LineChart(
            LineChartData(
              minY: minValue - padding,
              maxY: maxValue + padding,
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                drawVerticalLine: false,
                horizontalInterval: range > 0 ? range / 4 : 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(color: Colors.grey[300]!, strokeWidth: 1);
                },
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    interval: range > 0 ? range / 4 : 1,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Text(
                          value.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: displayData.length > 10
                        ? displayData.length / 5
                        : 1,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() < displayData.length &&
                          value.toInt() >= 0) {
                        final time = displayData[value.toInt()].timestamp;
                        return Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }
                      return Text('');
                    },
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  left: BorderSide(color: Colors.grey[300]!, width: 1),
                  bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: displayData.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value.value);
                  }).toList(),
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: widget.color,
                  barWidth: 3,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: widget.color,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        widget.color.withOpacity(0.4),
                        widget.color.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: widget.color.withOpacity(0.9),
                  tooltipRoundedRadius: 8,
                  tooltipPadding: EdgeInsets.all(8),
                  getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                    return touchedBarSpots.map((barSpot) {
                      final time = displayData[barSpot.x.toInt()].timestamp;
                      return LineTooltipItem(
                        '${barSpot.y.toStringAsFixed(1)} ${_getUnit()}\n${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                        TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    }).toList();
                  },
                ),
                touchCallback:
                    (FlTouchEvent event, LineTouchResponse? touchResponse) {},
                handleBuiltInTouches: true,
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        // Statistics row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatCard(
              'Min',
              minValue.toStringAsFixed(1),
              Icons.trending_down,
              Colors.red,
            ),
            _buildStatCard(
              'Max',
              maxValue.toStringAsFixed(1),
              Icons.trending_up,
              Colors.green,
            ),
            _buildStatCard(
              'Avg',
              (displayData.map((e) => e.value).reduce((a, b) => a + b) /
                      displayData.length)
                  .toStringAsFixed(1),
              Icons.analytics,
              Colors.blue,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '$value ${_getUnit()}',
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getUnit() {
    switch (widget.fieldNumber) {
      case '1':
        return 'cm';
      case '2':
        return '%';
      case '3':
        return '°C';
      case '4':
        return '%';
      default:
        return '';
    }
  }
}
