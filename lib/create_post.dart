import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kisaansetu/models/post_model.dart';
import 'package:kisaansetu/storage_methods.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Uint8List? _selectedImage;
  bool _isUploading = false;

  Future<Uint8List?> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      return await image.readAsBytes();
    }
    return null;
  }

  Future<void> _uploadPost() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Title and description cannot be empty!')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      String postId = FirebaseFirestore.instance.collection('posts').doc().id;
      String imageUrl = 'image_place_holder';

      if (_selectedImage != null) {
        imageUrl = await StorageMethods().getUploadedImage(_selectedImage!);
      }

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      String userName = userSnapshot['name'] ?? 'Unknown User';

      Post newPost = Post(
        postId: postId,
        userId: FirebaseAuth.instance.currentUser!.uid,
        userName: userName,
        title: _titleController.text,
        description: _descriptionController.text,
        imageUrl: imageUrl,
        timestamp: DateTime.now(),
        likes: [],
      );

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .set(newPost.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post uploaded successfully!')),
      );

      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedImage = null;
        _isUploading = false;
      });
    } catch (error) {
      print("Error uploading post: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload post!')),
      );
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        backgroundColor: Colors.green,
                      ),
                      onPressed: _isUploading ? null : _uploadPost,
                      child: _isUploading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Post', style: TextStyle(color: Colors.white)),
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        hintText: "Your Post title goes here...",
                        labelText: "Enter Title",
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: 10,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        hintText: "Your Description goes here...",
                        labelText: "Enter Your Description",
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      Uint8List? im = await pickImage();
                      if (im != null) {
                        setState(() {
                          _selectedImage = im;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.grey[200],
                          image: _selectedImage != null
                              ? DecorationImage(
                                  image: MemoryImage(_selectedImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _selectedImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(EvaIcons.cloudUploadOutline, size: 40, color: Colors.grey),
                                  SizedBox(height: 5),
                                  Text("Upload Image", style: TextStyle(color: Colors.grey[700])),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.memory(_selectedImage!, fit: BoxFit.cover),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
