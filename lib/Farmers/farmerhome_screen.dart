import 'package:animated_gradient/animated_gradient.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:kisaansetu/Farmers/advance_draweer_content.dart';
import 'package:kisaansetu/marketplace_screen.dart';
import 'package:kisaansetu/Farmers/tabs/add_product.dart';
import 'package:kisaansetu/Farmers/tabs/home_screen.dart';
import 'package:kisaansetu/Farmers/tabs/orders_screen.dart';
import 'package:kisaansetu/Farmers/user_products_screen.dart';

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
    borderRadius: BorderRadius.circular(30),
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
    Color(0xFF388E3C),
Color(0xFF2E7D32),
Color(0xFF66BB6A), 
Color(0xFF1B5E20),

  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
    ),
  ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(child: _screens[_selectedIndex]),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(left: 8.0,right: 8.0,top: 8.0,bottom: 13),
          child: GlassContainer(
            width: double.infinity,
            height: 70,
            blur: 15,
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            borderRadius: BorderRadius.circular(40),
            color: Colors.white.withOpacity(0.1), // Transparent effect
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              selectedItemColor: Colors.greenAccent,
              unselectedItemColor: Colors.white70,
              showSelectedLabels: true,
              showUnselectedLabels: false,
              currentIndex: _selectedIndex,
              items: const [
                BottomNavigationBarItem(icon: Icon(EvaIcons.home),backgroundColor: Colors.black, label: 'Home'),
                BottomNavigationBarItem(icon: Icon(EvaIcons.fileAdd),backgroundColor: Colors.black, label: 'Sell'),
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
