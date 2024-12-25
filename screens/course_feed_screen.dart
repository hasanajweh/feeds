import 'package:flutter/material.dart';
import 'package:ppu_feeds/Services/course_feed_service.dart';
import 'package:ppu_feeds/Services/like_service.dart';
import 'comment_feed_screen.dart';

class CourseFeedScreen extends StatefulWidget {
  final int courseId;
  final int sectionId;

  CourseFeedScreen({required this.courseId, required this.sectionId});

  @override
  _CourseFeedScreenState createState() => _CourseFeedScreenState();
}

class _CourseFeedScreenState extends State<CourseFeedScreen> {
  final CourseFeedService _service = CourseFeedService();
  final LikeService _likeService = LikeService();
  List<dynamic> posts = [];
  bool isLoading = true;
  String errorMessage = '';
  final TextEditingController _postController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      setState(() => isLoading = true);
      posts = await _service.fetchPosts(widget.courseId, widget.sectionId);
      setState(() => isLoading = false);
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> createPost() async {
    try {
      final body = _postController.text.trim();
      if (body.isEmpty) return;

      await _service.createPost(widget.courseId, widget.sectionId, body);
      _postController.clear();
      fetchPosts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post created successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> toggleLikePost(int postId) async {
    try {
      await _likeService.togglePostLike(widget.courseId, widget.sectionId, postId);
      fetchPosts();
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
        title: Text('Course Feed'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _postController,
                    decoration: InputDecoration(
                      hintText: 'Write a new post...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: createPost,
                  child: Text('Post'),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                    ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red)))
                    : posts.isEmpty
                        ? Center(child: Text('No posts available.'))
                        : ListView.builder(
                            itemCount: posts.length,
                            itemBuilder: (context, index) {
                              final post = posts[index];
                              return Card(
                                child: ListTile(
                                  title: Text(post['body'] ?? 'Untitled Post'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Author: ${post['author'] ?? 'Unknown'}'),
                                      Text('Date Posted: ${post['date_posted'] ?? ''}'),
                                      Row(
                                        children: [
                                          Text('Likes: ${post['like_count'] ?? 0}'),
                                          IconButton(
                                            icon: Icon(
                                              post['liked'] == true
                                                  ? Icons.thumb_up
                                                  : Icons.thumb_up_outlined,
                                              color: post['liked'] == true ? Colors.blue : null,
                                            ),
                                            onPressed: () => toggleLikePost(post['id']),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CommentFeedScreen(
                                          courseId: widget.courseId,
                                          postId: post['id'],
                                          sectionId: widget.sectionId,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
