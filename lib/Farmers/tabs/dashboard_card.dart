import 'dart:ui';
import 'package:animated_gradient/animated_gradient.dart';
import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final int totalProducts;
  final double totalRevenue;
  final int totalSales;
  final bool isLoading;

  DashboardCard({
    required this.totalProducts,
    required this.totalRevenue,
    required this.totalSales,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  elevation: 6,
  shadowColor: Colors.black26,
  color: Colors.white,
  child: ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: AnimatedGradient(
      colors: const [
  Color(0xFF43A047),
  Color(0xFF9CCC65),
  Color(0xFFFFF8E1), 
],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard Title
            Text(
              'Dashboard 🍅',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            // Glassmorphic Stats Section
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStat("Products", "$totalProducts", Icons.shopping_bag),
                      _buildStat("Revenue", "$totalRevenue Rs", Icons.currency_rupee_sharp),
                      _buildStat("Orders", "$totalSales", Icons.receipt_long),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
),

      ),
    );
  }

  Widget _buildStat(String title, String value, IconData icon) {
    return isLoading
        ? CircularProgressIndicator()
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.black, size: 35), 
              SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          );
  }
}
