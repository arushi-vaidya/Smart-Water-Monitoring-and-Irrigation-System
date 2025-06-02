class SensorData {
  final DateTime timestamp;
  final double value;

  SensorData({required this.timestamp, required this.value});

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      timestamp: DateTime.parse(json['created_at']),
      value: double.tryParse(json['field1']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class ThingSpeakResponse {
  final List<SensorData> feeds;
  final String channelName;

  ThingSpeakResponse({required this.feeds, required this.channelName});

  factory ThingSpeakResponse.fromJson(
    Map<String, dynamic> json,
    String fieldNumber,
  ) {
    List<SensorData> feeds = [];
    if (json['feeds'] != null) {
      for (var feed in json['feeds']) {
        if (feed[fieldNumber] != null) {
          feeds.add(
            SensorData(
              timestamp: DateTime.parse(feed['created_at']),
              value: double.tryParse(feed[fieldNumber].toString()) ?? 0.0,
            ),
          );
        }
      }
    }

    return ThingSpeakResponse(
      feeds: feeds,
      channelName: json['channel']?['name'] ?? 'Water Monitoring System',
    );
  }
}
