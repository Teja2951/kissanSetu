import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kisaansetu/Widgets_Homescreen/mandi_service.dart';
import 'package:kisaansetu/chatlist_screen.dart';
import 'package:kisaansetu/Farmers/farmer_dashboard.dart';
import 'package:kisaansetu/marketplace_screen.dart';

class AdvancedDrawerContent extends StatefulWidget {
  @override
  State<AdvancedDrawerContent> createState() => _AdvancedDrawerContentState();
}

class _AdvancedDrawerContentState extends State<AdvancedDrawerContent> {
  final user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> fetchUserData() async {
    if (user == null) {
      return "Guest User";
    }
    try {
      print(user!.uid);
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user!.uid).get();
          print(doc['name']);
      return doc.exists ? doc['name'] ?? "User" : "User";
    } catch (e) {
      return "User";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: fetchUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("Error loading data"));
        }

        String username = snapshot.data!;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF388E3C),
                  Color(0xFF2E7D32),
                  Color(0xFF66BB6A),
                  Color(0xFF1B5E20),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                // Header
                Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey[300],
                        child: Icon(Icons.person, size: 30, color: Colors.white),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user?.email ?? "No Email",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      _buildListTile(Icons.agriculture_rounded, 'Marketplace', MarketplaceScreen()),
                      _buildListTile(Icons.money, 'Dashboard', SellerDashboardScreen()),
                      _buildListTile(Icons.person_2_rounded, 'Profile', MarketplaceScreen()),
                      _buildListTile(Icons.contact_page, 'Contact Us', MarketplaceScreen()),
                      _buildListTile(Icons.chat, 'Negotiations', ChatListScreen()),

                    ],
                  ),
                ),

                Divider(),

                // Footer
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 20.0),
                        child: ElevatedButton(
                          onPressed: () {
                            _showLogoutDialog(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFDC143C),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                            minimumSize: Size(double.infinity, 0),
                          ),
                          child: Text(
                            'Log Out',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Text(
                        'Made with 😍 by Team Aavishkaar',
                        style: TextStyle(fontSize: 14, color: Colors.amber),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Are you sure?', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(
            'Do you really want to log out? You’ll need to log in again to access your profile.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              },
              child: Text('Log Out', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildListTile(IconData icon, String title, Widget screen,
      {Color iconColor = Colors.white}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
      ),
    );
  }
}
