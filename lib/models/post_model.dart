class Post {
  String postId;
  String userId;
  String userName;
  String title;
  String description;
  String? imageUrl;
  DateTime timestamp;
  List<String> likes;

  Post({
    required this.postId,
    required this.userId,
    required this.userName,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.timestamp,
    required this.likes,
  });

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'title': title,
      "description": description,
      'imageUrl': imageUrl,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'likes': likes,
    };
  }

  static Post fromMap(Map<String, dynamic> map) {
    return Post(
      postId: map['postId'],
      userId: map['userId'],
      userName: map['userName'],
      title: map['title'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      likes: List<String>.from(map['likes']),
    );
  }
}
