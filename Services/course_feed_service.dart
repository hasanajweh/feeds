import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CourseFeedService {
  final String baseUrl = 'http://feeds.ppu.edu/api/v1';

  Future<List<dynamic>> fetchPosts(int courseId, int sectionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Authentication token is missing. Please log in.');
      }

      final url = Uri.parse('$baseUrl/courses/$courseId/sections/$sectionId/posts');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authToken,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['posts'] ?? []).reversed.toList(); // Most recent first
      } else {
        throw Exception('Failed to fetch posts: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> createPost(int courseId, int sectionId, String body) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Authentication token is missing. Please log in.');
      }

      final url = Uri.parse('$baseUrl/courses/$courseId/sections/$sectionId/posts');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authToken,
        },
        body: jsonEncode({'body': body}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create post: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> likePost(int courseId, int sectionId, int postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Authentication token is missing. Please log in.');
      }

      final url = Uri.parse('$baseUrl/courses/$courseId/sections/$sectionId/posts/$postId/like');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authToken,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to like post: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
