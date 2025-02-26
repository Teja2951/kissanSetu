import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kisaansetu/Services/product_service.dart';
import 'package:kisaansetu/Farmers/update_product_screen.dart';
import 'package:intl/intl.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';

class UserProductsScreen extends StatelessWidget {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("M Y  L I S T I N G S",style: TextStyle(fontSize: 26),),centerTitle: true,elevation: 3,),
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

          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: products.length,
            itemBuilder: (context, index) {
              var product = products[index];
              return _buildProductCard(context, product);
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, DocumentSnapshot product) {
    bool isSold = product["isSold"] ?? false;
    bool isSeller = product["farmerId"] == userId;
    String category = product["category"] ?? "Unknown";
    Timestamp timestamp = product["createdAt"] ?? Timestamp.now();
    String formattedDate = DateFormat('dd MMM yyyy').format(timestamp.toDate());

    return Card(
      color: Colors.green[50]!,
      elevation: 6,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                  image: product["imageUrl"] != "image_url_placeholder"
                      ? DecorationImage(
                          image: NetworkImage(product["imageUrl"]),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: product["imageUrl"] == "image_url_placeholder" ? Colors.grey[200] : null,
                ),
                child: product["imageUrl"] == "image_url_placeholder"
                    ? Icon(Icons.image, size: 80, color: Colors.grey)
                    : null,
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Chip(
                  label: Text(
                    isSold ? "SOLD" : "AVAILABLE",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: isSold ? Colors.red : Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
              if (isSeller)
                Positioned(
                  top: 10,
                  right: 10,
                  child: ElevatedButton.icon(
                    onPressed: () => _editProduct(context, product),
                    icon: Icon(EvaIcons.editOutline, color: Colors.blueAccent),
                    label: Text("Edit", style: TextStyle(color: Colors.blueAccent)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 3,
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product["name"],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  "₹${product["price"]}",
                  style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text(category, style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.blueAccent,
                    ),
                    Text(
                      formattedDate,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                if (!isSeller)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text("Buy Now"),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editProduct(BuildContext context, DocumentSnapshot product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProductScreen(product: product)),
    );
  }
}
