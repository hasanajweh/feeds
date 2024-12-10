class Comment {
  final int id;
  final String body;
  final String datePosted;
  final String author;
  final int likesCount;

  Comment({
    required this.id,
    required this.body,
    required this.datePosted,
    required this.author,
    required this.likesCount,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      body: json['body'],
      datePosted: json['date_posted'],
      author: json['author'],
      likesCount: json['likes_count'] ?? 0,
    );
  }
}
