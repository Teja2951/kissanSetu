import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool isLiked = false;
  int likeCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchPostData();
  }

  Future<void> _fetchPostData() async {
    var postDoc = await FirebaseFirestore.instance.collection('posts').doc(widget.postId).get();
    if (postDoc.exists) {
      List likes = postDoc['likes'];
      setState(() {
        isLiked = likes.contains(FirebaseAuth.instance.currentUser!.uid);
        likeCount = likes.length;
      });
    }
  }

  void _toggleLike() async {
    var postRef = FirebaseFirestore.instance.collection('posts').doc(widget.postId);
    var userId = FirebaseAuth.instance.currentUser!.uid;

    if (isLiked) {
      await postRef.update({'likes': FieldValue.arrayRemove([userId])});
      setState(() {
        isLiked = false;
        likeCount--;
      });
    } else {
      await postRef.update({'likes': FieldValue.arrayUnion([userId])});
      setState(() {
        isLiked = true;
        likeCount++;
      });
    }
  }

  void _addComment() async {
    final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get();
    if (_commentController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('posts').doc(widget.postId).collection('comments').add({
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'userName': docSnapshot['name'],
        'comment': _commentController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _commentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('posts').doc(widget.postId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          var post = snapshot.data!;
          String imageUrl = post['imageUrl'];
          bool hasImage = imageUrl.isNotEmpty && imageUrl != 'image_place_holder';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(EvaIcons.closeCircle, size: 36),
                  ),
                ],
              ),
                if (hasImage)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.network(imageUrl, width: double.infinity, height: 250, fit: BoxFit.cover),
                  ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post['title'], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(post['description'], style: TextStyle(fontSize: 16)),
                      SizedBox(height: 10),
                      Text("Posted by ${post['userName']}", style: TextStyle(color: Colors.grey[600])),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(isLiked ? Icons.thumb_up : Icons.favorite_border, color: Colors.green),
                            onPressed: _toggleLike,
                          ),
                          Text("$likeCount likes"),
                        ],
                      ),
                      Divider(thickness: 1),
                      Text("Comments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      _buildCommentSection(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Write a comment...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send, color: Colors.green[700]),
              onPressed: _addComment,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentSection() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('posts').doc(widget.postId).collection('comments').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(10),
            child: Text("No comments yet. Be the first!", style: TextStyle(color: Colors.grey)),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var comment = snapshot.data!.docs[index];
            return ListTile(
              leading: CircleAvatar(child: Icon(Icons.person)),
              title: Text(comment['userName'], style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(comment['comment']),
            );
          },
        );
      },
    );
  }
}
