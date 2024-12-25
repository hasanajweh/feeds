import 'package:flutter/material.dart';
import 'package:ppu_feeds/Services/comment_feed_service.dart';
import 'package:ppu_feeds/Services/like_service.dart';

class CommentFeedScreen extends StatefulWidget {
  final int courseId;
  final int sectionId;
  final int postId;

  CommentFeedScreen({
    required this.courseId,
    required this.sectionId,
    required this.postId,
  });

  @override
  _CommentFeedScreenState createState() => _CommentFeedScreenState();
}

class _CommentFeedScreenState extends State<CommentFeedScreen> {
  final CommentFeedService _commentFeedService = CommentFeedService();
  final LikeService _likeService = LikeService();
  List<dynamic> comments = [];
  bool isLoading = true;
  String errorMessage = '';
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  Future<void> fetchComments() async {
    try {
      setState(() => isLoading = true);
      comments = await _commentFeedService.fetchComments(
        widget.courseId,
        widget.sectionId,
        widget.postId,
      );
      setState(() => isLoading = false);
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> toggleLikeComment(int commentId) async {
    try {
      await _likeService.toggleCommentLike(
        widget.courseId,
        widget.sectionId,
        widget.postId,
        commentId,
      );
      fetchComments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> addComment(String commentText) async {
    try {
      await _commentFeedService.addComment(
        widget.courseId,
        widget.sectionId,
        widget.postId,
        commentText,
      );
      commentController.clear();
      fetchComments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                    ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red)))
                    : ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return Card(
                            child: ListTile(
                              title: Text(comment['author'] ?? 'Unknown User'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(comment['body'] ?? 'No content available'),
                                  Text('Posted on: ${comment['date_posted'] ?? 'Unknown Date'}'),
                                  Row(
                                    children: [
                                      Text('Likes: ${comment['like_count'] ?? 0}'),
                                      IconButton(
                                        icon: Icon(
                                          comment['liked'] == true
                                              ? Icons.thumb_up
                                              : Icons.thumb_up_outlined,
                                          color: comment['liked'] == true ? Colors.blue : null,
                                        ),
                                        onPressed: () {
                                          toggleLikeComment(comment['id']);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (commentController.text.isNotEmpty) {
                      addComment(commentController.text);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
