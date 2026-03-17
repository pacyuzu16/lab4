class Post {
  final int id;       // 0 for posts not yet sent to the API
  final int userId;
  final String title;
  final String body;

  Post({
    this.id = 0,
    required this.userId,
    required this.title,
    required this.body,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }

  // id is excluded — the API assigns it on creation.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
    };
  }
}
