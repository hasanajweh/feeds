import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CommentFeedService {
  final String baseUrl = 'http://feeds.ppu.edu/api/v1';

  Future<List<dynamic>> fetchComments(int courseId, int sectionId, int postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Authentication token is missing. Please log in.');
      }

      final url = Uri.parse(
          '$baseUrl/courses/$courseId/sections/$sectionId/posts/$postId/comments');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authToken,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['comments'] ?? [];
      } else {
        throw Exception('Failed to fetch comments: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> addComment(int courseId, int sectionId, int postId, String body) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Authentication token is missing. Please log in.');
      }

      final url = Uri.parse(
          '$baseUrl/courses/$courseId/sections/$sectionId/posts/$postId/comments');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authToken,
        },
        body: jsonEncode({'body': body}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to add comment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> likeComment(int courseId, int sectionId, int postId, int commentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Authentication token is missing. Please log in.');
      }

      final url = Uri.parse(
          '$baseUrl/courses/$courseId/sections/$sectionId/posts/$postId/comments/$commentId/like');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authToken,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to like comment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
