class Product {
  String id;
  String name;
  String description;
  double price;
  String imageUrl;
  String category;
  bool isSold;
  String ownerId; // User who listed the product
  DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.isSold,
    required this.ownerId,
    required this.createdAt,
  });

  // Convert Product object to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isSold': isSold,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Convert Firestore Map to Product object
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'].toDouble(),
      imageUrl: map['imageUrl'],
      category: map['category'],
      isSold: map['isSold'],
      ownerId: map['ownerId'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
