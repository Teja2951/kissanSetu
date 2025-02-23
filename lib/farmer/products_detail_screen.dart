import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kisaansetu/farmer/order_product.dart';

class ProductDetailsScreen extends StatelessWidget {
  final DocumentSnapshot product;

  const ProductDetailsScreen({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product["name"]),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Product Image
            product["imageUrl"] != "image_url_placeholder"
                ? Image.network(product["imageUrl"], height: 200, fit: BoxFit.cover)
                : Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 60, color: Colors.grey),
                  ),
            const SizedBox(height: 20),
            // Product Details
            Text(
              product["name"],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Price: ₹${product["price"].toString()}",
              style: const TextStyle(fontSize: 20, color: Colors.green),
            ),
            const SizedBox(height: 10),
            Text(
              product["description"] ?? "No description available.",
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            // Buy Button
            ElevatedButton(
              onPressed: () async {
                String buyerId = FirebaseAuth.instance.currentUser!.uid;
                await OrderService().createOrder(
                  productId: product.id,
                  buyerId: buyerId,
                  sellerId: product["farmerId"],
                  price: product["price"],
                  category: product["category"],
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Product purchased successfully!")),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Buy", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
