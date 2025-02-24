import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kisaansetu/Farmers/farmerhome_screen.dart';
import 'package:kisaansetu/Services/product_service.dart';
import 'package:kisaansetu/Farmers/products_detail_screen.dart';
import 'package:kisaansetu/Farmers/update_product_screen.dart';

class MarketplaceScreen extends StatelessWidget {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Marketplace"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ProductService().getAllProducts(),
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
              print(product.data());
              return _buildAnimatedCard(context, product, index);
            },
          );
        },
      ),
    );
  }


Widget _buildAnimatedCard(BuildContext context, DocumentSnapshot product, int index) {
  return Hero(
    tag: product.id,
    child: AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
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
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    onPressed: () => _viewProductDetails(context, product),
                    child: const Text("Buy Now", style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _viewProductDetails(BuildContext context, DocumentSnapshot product) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: product)),
  );
}
}