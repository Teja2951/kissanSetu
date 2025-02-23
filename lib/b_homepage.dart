import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:kisaansetu/farmer/advance_draweer_content.dart';
import 'package:kisaansetu/farmer/chatlist_screen.dart';
import 'package:kisaansetu/farmer/marketplace_screen.dart';
import 'package:kisaansetu/settings_page.dart';

class BuyerHomepage extends StatefulWidget {
  const BuyerHomepage({super.key});

  @override
  State<BuyerHomepage> createState() => _BuyerHomepageState();
}

class _BuyerHomepageState extends State<BuyerHomepage> {
  int _selectedIndex = 0;


  @override
  Widget build(BuildContext context) {

    final List<Widget> _screens = [
      MarketplaceScreen(),
      ChatListScreen(),
      SettingsPage(),
  ];
    return Scaffold(
      body: SafeArea(child: _screens[_selectedIndex]),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GlassContainer(
          width: double.infinity,
          height: 70,
          blur: 15,
          border: Border.all(color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2), width: 1),
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.1), // Transparent effect
          child: BottomNavigationBar(
            backgroundColor: Colors.black,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            currentIndex: _selectedIndex,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.sell),backgroundColor: Colors.black, label: 'MarketPlace'),
              BottomNavigationBarItem(icon: Icon(Icons.chat),backgroundColor: Colors.black, label: 'Chat'),
              BottomNavigationBarItem(icon: Icon(Icons.settings),backgroundColor: Colors.black, label: 'Settings'),
            ],
            onTap: (index) {
              setState(() => _selectedIndex = index);
            },
          ),
        ),
      ),
    );
  }
}
