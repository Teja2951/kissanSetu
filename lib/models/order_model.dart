class Order {
  final String id;
  final String productId;
  final String buyerId;
  final String sellerId;
  final double price;
  final DateTime createdAt;
  final String status; // e.g., "pending", "paid", "completed"
  final String category;

  Order({
    required this.id,
    required this.productId,
    required this.buyerId,
    required this.sellerId,
    required this.price,
    required this.createdAt,
    required this.status,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'price': price,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      productId: map['productId'],
      buyerId: map['buyerId'],
      sellerId: map['sellerId'],
      price: map['price'],
      createdAt: DateTime.parse(map['createdAt']),
      status: map['status'],
      category: map['category']
    );
  }
}
