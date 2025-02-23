import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

class HomeScreen extends StatefulWidget {

  final VoidCallback call;

  HomeScreen({
    required this.call,
  });


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Solid Background
            Container(
              color: Colors.white,
            ),

            Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3), // Glass effect
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [


                        _customIconButton(Icons.menu, widget.call),
                        // App Name
                        Text(
                          "Kissan Setu",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[900], // Dark green
                          ),
                        ),

                        // Custom Buttons for Actions
                        Row(
                          children: [
                            _customIconButton(Icons.notifications, () {}),
                            const SizedBox(width: 10),
                            _customIconButton(Icons.person, () {}),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Square Glassmorphic Cards Section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 cards per row
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1, // Square cards
                      ),
                      itemCount: 6, // Change this dynamically
                      itemBuilder: (context, index) {
                        return GlassContainer(
                          width: double.infinity,
                          height: double.infinity,
                          blur: 10,
                          border: Border.all(color: Colors.green.withOpacity(0.2), width: 1),
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white.withOpacity(0.3), // Soft white-transparent
                          child: Center(
                            child: Text(
                              "Product ${index + 1}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.brown[800], // Earthy tone for text
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Custom Icon Button
  Widget _customIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.green[700]!.withOpacity(0.3), // Green tint with transparency
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.green[900], size: 24),
      ),
    );
  }
}
