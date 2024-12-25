import 'package:http/http.dart' as http;

class LikeService {
  final String baseUrl = 'http://feeds.ppu.edu/api/v1';

  Future<void> togglePostLike(int courseId, int sectionId, int postId) async {
    final url = Uri.parse(
        '$baseUrl/courses/$courseId/sections/$sectionId/posts/$postId/like');
    final response = await http.post(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to toggle like');
    }
  }

  Future<void> toggleCommentLike(
      int courseId, int sectionId, int postId, int commentId) async {
    final url = Uri.parse(
        '$baseUrl/courses/$courseId/sections/$sectionId/posts/$postId/comments/$commentId/like');
    final response = await http.post(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to toggle comment like');
    }
  }
}
