import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kisaansetu/Farmers/products_detail_screen.dart';
import 'package:kisaansetu/Services/chat_service.dart';
import 'package:kisaansetu/Services/product_service.dart';
import 'package:kisaansetu/chat_screen.dart';

class UserProfile extends StatefulWidget {
  final String uid;
  const UserProfile({super.key, required this.uid});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _fetchUserInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('No data found'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('User not found'));
          }

          Map<String, dynamic> userData = snapshot.data!;

          return SingleChildScrollView(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Header
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Image.asset('assets/profile_bg.jpg'),
                      Positioned(
                        top: 0,
                        left: 0,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(EvaIcons.closeCircle,
                          size: 36,
                          color: Colors.white,
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.8),
                              Colors.black.withOpacity(0.0),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userData["username"],
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
        
                              Text(
                                userData['email'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
        
                              Text(
                                'Member Since ${userData['joinedDate']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Stats Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(userData['totalProducts'].toString(), 'Total Products'),
                        const VerticalDivider(color: Colors.black, thickness: 1),
                        _buildStatCard(userData['activeProducts'].toString(), 'Active Products'),
                        const VerticalDivider(color: Colors.black, thickness: 1),
                        _buildStatCard(userData['rating'].toString(), 'Rating'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Divider(),

                  SizedBox(
                    height: 500,
                    child: _buildProducts()
                  ),

                  SizedBox(height: 10,),

                  // Chat Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _openChatModal(context, userData["username"], widget.uid);
                      },
                      icon: const Icon(Icons.chat, size: 24,color: Colors.white,),
                      label: const Text("Chat with Seller", style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }

  Future<Map<String, dynamic>> _fetchUserInfo() async {
    var userInfo = await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();

    int activeProducts = 0;
    int soldProducts = 0;
    int totalProducts = 0;

    var productsInfo = await FirebaseFirestore.instance
        .collection('products')
        .where("farmerId", isEqualTo: widget.uid)
        .get();

    for (var doc in productsInfo.docs) {
      totalProducts++;
      if (doc["isSold"] == true) {
        soldProducts++;
      } else {
        activeProducts++;
      }
    }

    DateTime timestamp = userInfo.data()!['createdAt'].toDate();
    String joinedDate = DateFormat('dd-MM-yyyy').format(timestamp);

    return {
      "username": userInfo.data()!['name'],
      "email": userInfo.data()!['email'],
      "joinedDate": joinedDate,
      "bio": userInfo.data()?['bio'] ?? "",
      "totalProducts": totalProducts,
      "activeProducts": activeProducts,
      "soldProducts": soldProducts,
      "rating": 5,
    };
  }

  void _openChatModal(BuildContext context, String sellerName, String sellerId) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      builder: (context) {
        return SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.green.shade200,
                  child: const Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(sellerName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text("Want to chat with the seller?", style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    String chatId = await ChatService().createOrGetChat(FirebaseAuth.instance.currentUser!.uid, sellerId, "some_product_id");
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatScreen(chatId: chatId, buyerId: FirebaseAuth.instance.currentUser!.uid, sellerId: sellerId)),
                    );
                  },
                  icon: const Icon(Icons.chat),
                  label: const Text("Start Chat"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProducts() {
    return StreamBuilder<QuerySnapshot>(
        stream: ProductService().getFarmerProducts(widget.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No products found"));
          }

          var products = snapshot.data!.docs;

          return GridView.builder(
            physics: NeverScrollableScrollPhysics(),
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
