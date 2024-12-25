import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeService {
  final String baseUrl = 'http://feeds.ppu.edu/api/v1';

  Future<List<dynamic>> fetchSubscriptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Authentication token is missing. Please log in.');
      }

      final url = Uri.parse('$baseUrl/subscriptions');
      final response = await http.get(
        url,
        headers: {
          'Authorization': authToken,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['subscriptions'] ?? [];
      } else {
        throw Exception('Failed to fetch subscriptions: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
