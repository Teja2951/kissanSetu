import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kisaansetu/farmer/chat_screen.dart';
import 'package:kisaansetu/farmer/chat_service.dart';
import 'package:kisaansetu/farmer/order_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final DocumentSnapshot product;

  const ProductDetailsScreen({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String sellerName = "Loading...";
  String sellerId = "";

  @override
  void initState() {
    super.initState();
    sellerId = widget.product["farmerId"];
    _fetchSellerName();
  }

  void _fetchSellerName() async {
    DocumentSnapshot sellerDoc = await FirebaseFirestore.instance.collection("users").doc(sellerId).get();
    if (sellerDoc.exists) {
      setState(() {
        sellerName = sellerDoc["name"];
      });
    }
  }

  void _openChatModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      builder: (context) {
        return SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.green.shade200,
                  child: const Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(sellerName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text("Want to chat with the seller?", style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                String chatId = await ChatService().createOrGetChat(FirebaseAuth.instance.currentUser!.uid, sellerId, widget.product['id']);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatScreen(chatId: chatId, buyerId: FirebaseAuth.instance.currentUser!.uid, sellerId: sellerId)),
                );
              },
                  icon: const Icon(Icons.chat),
                  label: const Text("Start Chat"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.product["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: widget.product["imageUrl"] != "image_url_placeholder"
                  ? Image.network(widget.product["imageUrl"], height: 220, width: double.infinity, fit: BoxFit.cover)
                  : Container(
                      height: 220,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, size: 60, color: Colors.grey),
                    ),
            ),
            const SizedBox(height: 20),

            // 🏷️ Seller Chip
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => _openChatModal(context),
                child: Chip(
                  avatar: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  label: Text(sellerName),
                  backgroundColor: Colors.green.shade100,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.product["name"], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text("Price: ₹${widget.product["price"]}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.green)),
                      const SizedBox(height: 10),
                      Text(widget.product["description"] ?? "No description available.", style: const TextStyle(fontSize: 16, color: Colors.black54)),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),

            // 🛒 Buy Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  String buyerId = FirebaseAuth.instance.currentUser!.uid;
                  await OrderService().createOrder(
                    productId: widget.product.id,
                    buyerId: buyerId,
                    sellerId: sellerId,
                    price: widget.product["price"],
                    category: widget.product["category"],
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Product purchased successfully!")),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  elevation: 5,
                ),
                child: const Text("Buy Now", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
