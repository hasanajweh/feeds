import 'package:flutter/material.dart';
import 'package:ppu_feeds/Services/course_feed_service.dart';
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

  Future<void> likePost(int postId) async {
    try {
      await _service.likePost(widget.courseId, widget.sectionId, postId);
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
      appBar: AppBar(title: Text('Course Feed')),
      drawer: Drawer( // Drawer added
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'PPU Feeds',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            ListTile(
              leading: Icon(Icons.subscriptions),
              title: Text('Feeds'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.pushNamed(context, '/feeds');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Post creation section
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
          // Posts section
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
                                            icon: Icon(Icons.thumb_up),
                                            onPressed: () => likePost(post['id']),
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
