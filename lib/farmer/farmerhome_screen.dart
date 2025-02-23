import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:kisaansetu/farmer/advance_draweer_content.dart';
import 'package:kisaansetu/farmer/marketplace_screen.dart';
import 'package:kisaansetu/farmer/tabs/add_product.dart';
import 'package:kisaansetu/farmer/tabs/home_screen.dart';
import 'package:kisaansetu/farmer/tabs/orders_screen.dart';
import 'package:kisaansetu/farmer/user_products_screen.dart';

class FarmerHomeScreen extends StatefulWidget {
  @override
  _FarmerHomeScreenState createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  final AdvancedDrawerController _advancedDrawerController = AdvancedDrawerController();

  
  void _callSideBar() {
    _advancedDrawerController.showDrawer();
  }

  int _selectedIndex = 0;


  @override
  Widget build(BuildContext context) {

    final List<Widget> _screens = [
    HomeScreen(call: _callSideBar,),
    AddProductScreen(),
    OrdersScreen(),
    //MarketplaceScreen(),
    UserProductsScreen()
  ];
    return AdvancedDrawer(
      controller: _advancedDrawerController,
      rtlOpening: false,
      drawer: AdvancedDrawerContent(),
      childDecoration: BoxDecoration(
    borderRadius: BorderRadius.circular(30), // Adjust corner radius
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 10,
        offset: Offset(0, 5),
      ),
    ],
  ),
  backdrop: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
  colors: [
    Color(0xFF388E3C), // Medium Green (Main Theme)
Color(0xFF2E7D32), // Dark Green
Color(0xFF66BB6A), // Light Green
Color(0xFF1B5E20), // Deep Forest Green

  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
    ),
  ),
      child: Scaffold(
        body: SafeArea(child: _screens[_selectedIndex]),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GlassContainer(
            width: double.infinity,
            height: 70,
            blur: 15,
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.1), // Transparent effect
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,
              showSelectedLabels: true,
              showUnselectedLabels: false,
              currentIndex: _selectedIndex,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home),backgroundColor: Colors.black, label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.add_circle),backgroundColor: Colors.black, label: 'Sell'),
                BottomNavigationBarItem(icon: Icon(Icons.receipt_long),backgroundColor: Colors.black, label: 'My Orders'),
                BottomNavigationBarItem(icon: Icon(Icons.agriculture),backgroundColor: Colors.black, label: 'My Listings'),
              ],
              onTap: (index) {
                setState(() => _selectedIndex = index);
              },
            ),
          ),
        ),
      ),
    );
  }
}
