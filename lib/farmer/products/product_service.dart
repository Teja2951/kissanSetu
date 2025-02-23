import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = "products";

  // 🚀 Add Product
  Future<void> addProduct({
    required String farmerId,
    required String name,
    required double price,
    required String description,
    required String imageUrl,
    required String category,
  }) async {
    try {
      var uuid = Uuid();
      String orderId = uuid.v4();
      await _firestore.collection(collectionName).add({
        "id": orderId,
        "farmerId": farmerId,
        "name": name,
        "price": price,
        "description": description,
        "imageUrl": imageUrl,
        "category": category,
        "isSold": false, // Default value
        "createdAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding product: $e");
    }
  }

  // 🔍 Fetch All Products
  Stream<QuerySnapshot> getProducts() {
    return _firestore.collection(collectionName).orderBy("createdAt", descending: true).snapshots();
  }

  // 🔍 Fetch Products of a Specific Farmer
  Stream<QuerySnapshot> getFarmerProducts(String farmerId) {
    return _firestore.collection(collectionName).where("farmerId", isEqualTo: farmerId).snapshots();
  }

  Stream<QuerySnapshot> getAllProducts() {
    return _firestore.collection(collectionName).where("isSold", isEqualTo: false).snapshots();
  }

  

  // ✏️ Update Product
  Future<void> updateProduct(String productId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection(collectionName).doc(productId).update(updatedData);
    } catch (e) {
      print("Error updating product: $e");
    }
  }

  // ❌ Delete Product
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection(collectionName).doc(productId).delete();
    } catch (e) {
      print("Error deleting product: $e");
    }
  }
}
