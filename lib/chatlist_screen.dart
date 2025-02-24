import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Negotiations",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("chats").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var chats = snapshot.data!.docs.where((chat) {
            return chat.id.contains(currentUserId);
          }).toList();

          if (chats.isEmpty) {
            return const Center(
              child: Text(
                "No conversations yet.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            itemBuilder: (context, index) {
              var chat = chats[index];
              String chatId = chat.id;
              List<String> participants = chatId.split("_");
              
              String chatPartnerId = participants.first == currentUserId ? participants.last : participants.first;

              String lastMessage = chat["lastMessage"] ?? "No messages yet";
              Timestamp? timestamp = chat["timestamp"];
              DateTime? time = timestamp?.toDate();

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection("users").doc(chatPartnerId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const SizedBox();
                  }

                  var user = userSnapshot.data!;
                  String chatPartnerName = user["name"] ?? "Unknown User";
                  //String chatPartnerImage = user["profilePic"] ?? ""; // Assuming profile pic exists

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 8), // Space between cards
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12), // Better Padding
                      // leading: CircleAvatar(
                      //   radius: 28,
                      //   backgroundColor: Colors.teal.shade100,
                      //   backgroundImage: chatPartnerImage.isNotEmpty ? NetworkImage(chatPartnerImage) : null,
                      //   child: chatPartnerImage.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
                      // ),
                      title: Text(
                        chatPartnerName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      trailing: time != null
                          ? Text(
                              _formatTime(time),
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            )
                          : null,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              chatId: chatId,
                              buyerId: currentUserId,
                              sellerId: chatPartnerId,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    Duration diff = DateTime.now().difference(time);
    if (diff.inDays > 0) {
      return "${diff.inDays}d ago";
    } else if (diff.inHours > 0) {
      return "${diff.inHours}h ago";
    } else if (diff.inMinutes > 0) {
      return "${diff.inMinutes}m ago";
    } else {
      return "Just now";
    }
  }
}
