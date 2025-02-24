import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:uuid/uuid.dart';
import 'package:kisaansetu/models/order_model.dart' as om;

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String ordersCollection = "orders";

  // Simulate a payment and create an order
  Future<void> createOrder({
    required String productId,
    required String buyerId,
    required String sellerId,
    required double price,
    required String category,
  }) async {
    try {
      // Simulate a payment process here (later integrate Razorpay)
      // If payment is successful:
      var uuid = Uuid();
      String orderId = uuid.v4();

      // Create an order
      om.Order newOrder = om.Order(
        id: orderId,
        productId: productId,
        buyerId: buyerId,
        sellerId: sellerId,
        price: price,
        createdAt: DateTime.now(),
        status: "paid",
        category: category,
      );

      await _firestore.collection(ordersCollection).doc(orderId).set(newOrder.toMap());

      // Update the product to mark it as sold
      await _firestore.collection("products").doc(productId).update({
        'isSold': true,
      });

      // Optionally, you can update the seller's transactions
      // For example, you can add this order info to a separate "transactions" collection or under the seller's document

      print("Order created and product marked as sold.");
    } catch (e) {
      print("Error creating order: $e");
    }
  }

  Future<Map<String, dynamic>> getStats(String farmerId) async {
    try {
      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: farmerId)
          .get();

      double totalRevenue = 0;
      int totalSales = ordersSnapshot.docs.length;

      for (var order in ordersSnapshot.docs) {
        totalRevenue += (order['price'] as num).toDouble();
      }

      return {
        'totalRevenue': totalRevenue,
        'totalSales': totalSales,
      };
    } catch (e) {
      print("Error fetching order stats: $e");
      return {'totalRevenue': 0, 'totalSales': 0};
    }
  }
}
