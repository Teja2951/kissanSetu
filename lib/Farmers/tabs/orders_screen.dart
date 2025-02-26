import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrdersScreen extends StatefulWidget {
  OrdersScreen({Key? key}) : super(key: key);

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final String sellerId = FirebaseAuth.instance.currentUser!.uid;
  final List<Color> cardColors = [
    Colors.blue[50]!,
    Colors.green[50]!,
    Colors.purple[50]!,
    Colors.orange[50]!,
    Colors.pink[50]!,
    Colors.teal[50]!,
    Colors.indigo[50]!,
  ];
  final Random _random = Random();
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchOrdersWithDetails();
  }

  Future<List<Map<String, dynamic>>> _fetchOrdersWithDetails() async {
    var ordersSnapshot = await FirebaseFirestore.instance
        .collection("orders")
        .where("sellerId", isEqualTo: sellerId)
        .get();

    if (ordersSnapshot.docs.isEmpty) {
      return [];
    }

    List<Map<String, dynamic>> orders = [];
    for (var doc in ordersSnapshot.docs) {
      var order = doc.data();
      var details = await _fetchOrderDetails(order['buyerId'], order['productId']);
      orders.add({
        "id": doc.id,
        ...order,
        ...details,
      });
    }
    return orders;
  }

  Future<Map<String, String>> _fetchOrderDetails(String buyerId, String productId) async {
    String buyerName = "Unknown";
    String productName = "Unknown Product";

    var buyerSnapshot = await FirebaseFirestore.instance.collection("users").doc(buyerId).get();
    if (buyerSnapshot.exists) {
      buyerName = buyerSnapshot.data()?["name"] ?? "Unknown";
    }

    var productSnapshot = await FirebaseFirestore.instance.collection("products").doc(productId).get();
    if (productSnapshot.exists) {
      productName = productSnapshot.data()?["name"] ?? "Unknown Product";
    }

    return {"buyerName": buyerName, "productName": productName};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _ordersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("No transactions yet.", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  );
                }

                var orders = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    var order = orders[index];
                    Color randomCardColor = cardColors[_random.nextInt(cardColors.length)];

                    return Card(
                      elevation: 4,
                      color: randomCardColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order["productName"] ?? "Unknown Product",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text("Buyer: ${order["buyerName"] ?? "Unknown"}", style: TextStyle(color: Colors.grey[700])),
                            Text("Category: ${order['category']}", style: TextStyle(color: Colors.grey[700])),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "₹${order['price'].toString()}",
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                                _buildStatusChip(order['status']),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Date: ${order['createdAt']}",
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case "pending":
        statusColor = Colors.orange;
        break;
      case "paid":
        statusColor = Colors.blue;
        break;
      case "completed":
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
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
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "My Transactions",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Icon(Icons.shopping_cart, size: 30, color: Colors.white),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "View all your sales and transactions",
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
