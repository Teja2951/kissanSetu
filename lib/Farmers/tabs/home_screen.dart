import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:kisaansetu/CropAnalysis.dart';
import 'package:kisaansetu/Farmers/farmer_dashboard.dart';
import 'package:kisaansetu/Farmers/tabs/custom_feautures';
import 'package:kisaansetu/Services/order_service.dart';
import 'package:kisaansetu/Services/product_service.dart';

class HomeScreen extends StatefulWidget {

  final VoidCallback call;

  HomeScreen({
    required this.call,
  });


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final ProductService _productService = ProductService();
  final OrderService _orderService = OrderService();

  int _totalProducts = 0;
  int _totalSales = 0;
  double _totalRevenue = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    String farmerId = FirebaseAuth.instance.currentUser!.uid;

    try {
      int productCount = await _productService.getTotalProducts(farmerId);
      Map<String, dynamic> stats = await _orderService.getStats(farmerId);

      setState(() {
        _totalProducts = productCount;
        _totalSales = stats['totalSales'];
        _totalRevenue = stats['totalRevenue'];
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching stats: $e");
    }
  }

  Widget _buildStat(String title, String value, IconData icon) {
    return (_isLoading)? CircularProgressIndicator() : Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 5),
        Icon(icon),
        Text(title, style: TextStyle(fontSize: 14, color: Colors.white70)),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> _features = [
    {
      'title': 'Live Mandi Rates',
      'icon': Icons.trending_up,
      'onTap': () {
        
      },
    },
    {
      'title': 'Crop Doctor',
      'icon': Icons.health_and_safety,
      'onTap': () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CropDoctorScreen())
        );
      }
    },
    {
      'title': 'Weather Forecast',
      'icon': Icons.cloud,
      'onTap': () {
        
      },
    },
    {
      'title': 'Agri News',
      'icon': Icons.article,
      'onTap': () {
        
      },
    },
  ];
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
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                            _customIconButton(Icons.person, () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SellerDashboardScreen())
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 150,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 4,
                                  color: Colors.green.shade400, // Gradient feel
                                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStat("Listed Products", "${_totalProducts}",Icons.abc),
                        _buildStat("Revenue", "${_totalRevenue}",Icons.aspect_ratio),
                        _buildStat("Total Orders", "${_totalSales}",Icons.ac_unit_outlined),
                      ],
                    ),
                                  ),
                                ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: GridView.builder(
                      itemCount: _features.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.2,
                      ),
                      itemBuilder: (context, index) {
                        return FeatureCard(
                          title: _features[index]['title'],
                          icon: _features[index]['icon'],
                          onTap: _features[index]['onTap'],
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
