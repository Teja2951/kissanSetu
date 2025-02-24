import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createOrGetChat(String buyerId, String sellerId, String productId) async {
    String chatId = "${buyerId}_$sellerId"; // Unique chat ID

    DocumentReference chatDocRef = _firestore.collection("chats").doc(chatId);

    DocumentSnapshot chatSnapshot = await chatDocRef.get();

    if (!chatSnapshot.exists) {
      await chatDocRef.set({
        "buyerId": buyerId,
        "sellerId": sellerId,
        "productId": productId,
        "lastMessage": "",
        "timestamp": FieldValue.serverTimestamp()
      });
    }

    return chatId;
  }
}
