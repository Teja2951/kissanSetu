import 'package:carousel_slider/carousel_slider.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:kisaansetu/CropAnalysis.dart';
import 'package:kisaansetu/Farmers/chatbot.dart';
import 'package:kisaansetu/Farmers/farmer_dashboard.dart';
import 'package:kisaansetu/Farmers/tabs/cards.dart';
import 'package:kisaansetu/Farmers/tabs/dashboard_card.dart';
import 'package:kisaansetu/Services/order_service.dart';
import 'package:kisaansetu/Services/product_service.dart';
import 'package:kisaansetu/Widgets_Homescreen/mandi_service.dart';
import 'package:kisaansetu/community.dart';
import 'package:kisaansetu/government_schemes.dart';
import 'package:kisaansetu/user_profile.dart';

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

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> _features = [
  {
    'title': 'Mandi Rates',
    'icon': Icons.trending_up,
    'color1': Colors.orange.shade600,
    'color2': Colors.orange.shade300,
    'onTap': () {
      print('object');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MandiSelector())
      );
    },
  },
  {
    'title': 'Crop Doctor',
    'icon': Icons.health_and_safety,
    'color1': Colors.green.shade600,
    'color2': Colors.green.shade300,
    'onTap': () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CropDoctorScreen())
      );
    }
  },
  {
    'title': 'Chat Saathi',
    'icon': EvaIcons.messageCircleOutline,
    'color1': Colors.blue.shade600,
    'color2': Colors.blue.shade300,
    'onTap': () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatBotScreen()));
    },
  },
  {
    'title': 'Community',
    'icon': Icons.people,
    'color1': Colors.purple.shade600,
    'color2': Colors.purple.shade300,
    'onTap': () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => CommunityScreen()));
    },
  },
  {
    'title': 'Goverment Schemes',
    'icon': Icons.receipt_long_outlined,
    'color1': Colors.indigo.shade600,
    'color2': Colors.indigo.shade300,
    'onTap': () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => GovernmentSchemes()));
    },
  },
];

 final List<String> bannerImages = [
    'https://img.freepik.com/free-vector/farm-template-design_23-2150178969.jpg',
    'https://img.freepik.com/free-vector/farm-template-design_23-2150178969.jpg',
    'https://img.freepik.com/free-vector/hand-drawn-agriculture-company-sale-banner_23-2149696779.jpg',
  ];

    return Scaffold(
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Stack(
          children: [

            // green gradient overlay
            ClipPath(
              clipper: CustomCurveClipper(),
              child: Container(
                  height: 250,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
    Color(0xFF6F8F2D), 
    Color.fromARGB(255, 129, 167, 23), 
  ],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
)


                  ),
                ),
            ),

            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [


                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        customIconButton(EvaIcons.menu2, widget.call),

                        Text(
                          'Kissan Setu',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        customIconButton(
                          EvaIcons.person,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UserProfile(uid: FirebaseAuth.instance.currentUser!.uid,)),
                            );
                          }
                        )
                      ],
                    ),

                    SizedBox(height: 50,),

                  //dashboard view
                  DashboardCard(totalProducts: _totalProducts, totalRevenue: _totalRevenue, totalSales: _totalSales, isLoading: _isLoading),
                  
                  SizedBox(height: 20,),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "🚜 Latest News",
                      style: TextStyle(
                        //decoration: TextDecoration.underline,
                        fontSize: 29,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ),

                  SizedBox(
                    height: 10,
                  ),

                  SizedBox(
                    child: CarouselSlider(
      options: CarouselOptions(
        height: 180.0,
        autoPlay: true,
        enlargeCenterPage: true,
        aspectRatio: 16/9,
        viewportFraction: 1,
      ),
      items: bannerImages.map((image) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(image),
        );
      }).toList(),
    ),
                  ),

                  SizedBox(height: 10,),


                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "🚜 Agri Hub",
                      /*
                      🔍 What Do You Need Today?
                      📌 Select a Feature
                      ✨ Get Started
                      */
                      style: TextStyle(
                        //decoration: TextDecoration.underline,
                        fontSize: 29,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ),

                  SizedBox(height: 20,),


                  SizedBox(
                    height: 600,
                    //padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      itemCount: _features.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.2,
                      ),
                      itemBuilder: (context, index) {
                        return CustomCard(
                          title: _features[index]['title'],
                          icon: _features[index]['icon'],
                          onTap: _features[index]['onTap'],
                          color: _features[index]['color1'],
                        );
                      },
                    ),
                  ),
                ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  } 

  Widget customIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black, size: 24),
      ),
    );
  }

}

class CustomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
        size.width / 2, size.height + 30, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}