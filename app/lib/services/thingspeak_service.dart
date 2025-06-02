import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sensor_data.dart';

class ThingSpeakService {
  static const String baseUrl = 'https://api.thingspeak.com/channels';

  // Replace with your actual ThingSpeak channel ID and API key
  static const String channelId = '2975376';
  static const String readApiKey = '6M40IIM3BS2SRQ1Q';

  static Future<ThingSpeakResponse> getFieldData(
    String fieldNumber, {
    int results = 100,
  }) async {
    try {
      final url =
          '$baseUrl/$channelId/feeds.json?api_key=$readApiKey&results=$results';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ThingSpeakResponse.fromJson(data, 'field$fieldNumber');
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  static Future<Map<String, dynamic>> getChannelInfo() async {
    try {
      final url = '$baseUrl/$channelId.json?api_key=$readApiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load channel info');
      }
    } catch (e) {
      throw Exception('Error fetching channel info: $e');
    }
  }
}
