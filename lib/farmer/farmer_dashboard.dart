import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kisaansetu/farmer/sales_chart.dart';

class SellerDashboardScreen extends StatefulWidget {
  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  final String sellerId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Seller Dashboard")),
      body: FutureBuilder(
        future: _fetchDashboardData(),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Text("Error loading data"));
          }

          var data = snapshot.data!;
          Map<String, int> categorySales = data["categorySales"];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 📊 Pie Chart for Category Sales
                SizedBox(height: 200,
                  child:  categorySales.isNotEmpty
      ? CategorySalesPieChart(categorySales: categorySales)
      : Center(child: Text("No sales data available", style: TextStyle(fontSize: 16, color: Colors.grey))),

                ),
                
                // 📌 Card for Earnings & Product Stats
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Total Earnings: ₹${data['totalEarnings']}",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                        SizedBox(height: 8),
                        Text("Active Listings: ${data['activeProducts']}", style: TextStyle(fontSize: 16)),
                        Text("Sold Products: ${data['soldProducts']}", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // 📦 Orders List
                Expanded(child: _buildOrdersList()),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchDashboardData() async {
    var productsSnapshot = await FirebaseFirestore.instance
        .collection("products")
        .where("farmerId", isEqualTo: sellerId)
        .get();

    var ordersSnapshot = await FirebaseFirestore.instance
        .collection("orders")
        .where("sellerId", isEqualTo: sellerId)
        .where("isSold", isEqualTo: true)
        .get();

    double totalEarnings = 0;
    int activeProducts = 0;
    int soldProducts = 0;
    Map<String, int> categorySales = {};


    // abhi its for products later on remove this and add for orders orders mai category push
    for (var doc in productsSnapshot.docs) {
      if (doc["isSold"] == true) {
        soldProducts++;
        String category = doc["category"];
      categorySales[category] = (categorySales[category] ?? 0) + 1;
      } else {
        activeProducts++;
        String category = doc["category"];
      categorySales[category] = (categorySales[category] ?? 0) + 1;
      }
    }

    for (var order in ordersSnapshot.docs) {
      totalEarnings += order["price"] as double;
      
      // 🔥 Process category sales dynamically
      // String category = order["category"];
      // categorySales[category] = (categorySales[category] ?? 0) + 1;
    }

    print(categorySales);

    return {
      "totalEarnings": totalEarnings,
      "activeProducts": activeProducts,
      "soldProducts": soldProducts,
      "categorySales": categorySales, // 🔥 Returning category sales
    };
  }

  // 🛍 Improved List of Orders
  Widget _buildOrdersList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("orders")
          .where("sellerId", isEqualTo: sellerId)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No Orders Yet"));
        }

        var orders = snapshot.data!.docs;

        // Group orders by date
        Map<String, List<QueryDocumentSnapshot>> groupedOrders = {};
        for (var order in orders) {
          String date = order["createdAt"]; 
          if (!groupedOrders.containsKey(date)) {
            groupedOrders[date] = [];
          }
          groupedOrders[date]!.add(order);
        }

        return ListView.builder(
          itemCount: groupedOrders.keys.length,
          itemBuilder: (context, index) {
            String date = groupedOrders.keys.elementAt(index);
            List<QueryDocumentSnapshot> dailyOrders = groupedOrders[date]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    date, // Show the date
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ),
                ...dailyOrders.map((order) {
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection("users").doc(order["buyerId"]).get(),
                    builder: (context, buyerSnapshot) {
                      String buyerName = "Unknown Buyer";
                      if (buyerSnapshot.hasData && buyerSnapshot.data!.exists) {
                        buyerName = buyerSnapshot.data!["name"];
                      }
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          title: Text("Buyer: $buyerName", style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Total: ₹${order["price"]}"),
                          trailing: Chip(
                            label: Text(order["status"]),
                            backgroundColor: _getStatusColor(order["status"]),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ],
            );
          },
        );
      },
    );
  }

  // 🎨 Function to Change Status Color
  Color _getStatusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "Shipped":
        return Colors.blue;
      case "Paid":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
