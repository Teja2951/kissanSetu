import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kisaansetu/farmer/products/product_service.dart';
import 'package:kisaansetu/farmer/update_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Listings")),
      body: StreamBuilder<QuerySnapshot>(
        stream: ProductService().getFarmerProducts(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No products found"));
          }

          var products = snapshot.data!.docs;

          return GridView.builder(
            padding: EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 products per row
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              var product = products[index];
              return _buildAnimatedCard(context, product, index);
            },
          );
        },
      ),
    );
  }


Widget _buildAnimatedCard(BuildContext context, DocumentSnapshot product, int index) {
  bool isSold = product["isSold"] ?? false; 

  return Hero(
    tag: product.id,
    child: AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)), // Staggered animation
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            // Product Image with overlay
            Positioned.fill(
              child: product["imageUrl"] != "image_url_placeholder"
                  ? Image.network(
                      product["imageUrl"],
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, size: 60, color: Colors.grey),
                    ),
            ),

            // Gradient overlay for readability
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Product Info
            Positioned(
              bottom: 15,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product["name"],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "₹${product["price"].toString()}",
                    style: const TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            Positioned(
              top: 10,
              left: 10,
              child: Chip(
                label: Text(
                  isSold ? "SOLD" : "NOT SOLD",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                backgroundColor: isSold ? Colors.red : Colors.green, // Red for sold, green for available
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
              
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => _editProduct(context, product),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 6, spreadRadius: 1),
                    ],
                  ),
                  child: const Icon(Icons.edit, size: 18, color: Colors.blueAccent),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  void _editProduct(BuildContext context, DocumentSnapshot product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>   EditProductScreen(product: product)),
    );
  }
}
