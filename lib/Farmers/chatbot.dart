import 'dart:typed_data';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';

class ChatBotScreen extends StatefulWidget {
  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  Uint8List? _selectedImage;


  Future<void> _sendMessage() async {
    String text = _controller.text.trim();
    Uint8List? imageBytes = _selectedImage;

    if (text.isEmpty && imageBytes == null) return;

    setState(() {
      if (text.isNotEmpty) {
        _messages.add({'text': text, 'isUser': true});
      }
      if (imageBytes != null) {
        _messages.add({'image': imageBytes, 'isUser': true});
      }
      _selectedImage = null;
      _controller.clear();
    });

    // Prepare parts for Gemini API
    List<Part> parts = [];
    if (text.isNotEmpty) {
      parts.add(Part.text(text));
    }
    if (imageBytes != null) {
      parts.add(Part.inline(InlineData.fromUint8List(imageBytes)));
    }

    try {
      final response = await Gemini.instance.prompt(parts: parts);
      final output = response?.output;
      if (output != null) {
        setState(() {
          _messages.add({'text': output, 'isUser': false});
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImage = imageBytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['isUser'] as bool;
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.green[100] : Colors.green[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: message['text'] != null
                        ? Text(message['text'])
                        : Image.memory(message['image']),
                  ),
                );
              },
            ),
          ),

          // Image Preview (if selected)
          if (_selectedImage != null)
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.green[50]),
              child: Column(
                children: [
                  Image.memory(_selectedImage!, height: 150),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                    child: Text("Remove Image", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),

          // Input field & buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(EvaIcons.image),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(EvaIcons.paperPlaneOutline,size: 24,),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.green[700],
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "ChatSaathi",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Icon(EvaIcons.messageCircle, size: 30, color: Colors.white),
            ],
          ),
          const Text(
            "Ask you queries instantly",
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
