import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kisaansetu/Services/order_service.dart';
import 'package:kisaansetu/user_profile.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(widget.product["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: widget.product["imageUrl"] != "image_url_placeholder"
                    ? Image.network(widget.product["imageUrl"], height: 250, width: double.infinity, fit: BoxFit.cover)
                    : Container(
                        height: 250,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 80, color: Colors.grey),
                      ),
              ),
              const SizedBox(height: 20),
              
              // Seller Name Section
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfile(uid: sellerId))),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text("Seller: $sellerName", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 10),

              // Product Details Section
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
                        Text("Price: ₹${widget.product["price"]}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                        const SizedBox(height: 10),
                        Text(widget.product["description"] ?? "No description available.",
                            style: const TextStyle(fontSize: 16, color: Colors.black87)),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              
              // Buy Button
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    elevation: 6,
                  ),
                  child: const Text("Buy Now", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
