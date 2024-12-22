import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FeedsService {
  final String baseUrl = 'http://feeds.ppu.edu/api/v1';

  Future<List<dynamic>> fetchCourses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Authentication token is missing. Please log in.');
      }

      final url = Uri.parse('$baseUrl/courses');
      final response = await http.get(
        url,
        headers: {
          'Authorization': authToken,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['courses'] ?? [];
      } else {
        throw Exception('Failed to fetch courses: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

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

  Future<List<dynamic>> fetchSections(int courseId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Authentication token is missing. Please log in.');
      }

      final url = Uri.parse('$baseUrl/courses/$courseId/sections');
      final response = await http.get(
        url,
        headers: {
          'Authorization': authToken,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['sections'] ?? [];
      } else {
        throw Exception('Failed to fetch sections: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> toggleSubscription(
    int courseId,
    int sectionId,
    bool isSubscribed,
    {int? subscriptionId}
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Authentication token is missing. Please log in.');
      }

      if (isSubscribed) {
        // Unsubscribe logic
        if (subscriptionId == null) {
          throw Exception('Subscription ID is required to unsubscribe.');
        }
        final url = Uri.parse('$baseUrl/courses/$courseId/sections/$sectionId/subscribe/$subscriptionId');
        final response = await http.delete(
          url,
          headers: {
            'Authorization': authToken,
          },
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to unsubscribe: ${response.body}');
        }
      } else {
        // Subscribe logic
        final url = Uri.parse('$baseUrl/courses/$courseId/sections/$sectionId/subscribe');
        final response = await http.post(
          url,
          headers: {
            'Authorization': authToken,
          },
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to subscribe: ${response.body}');
        }
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
