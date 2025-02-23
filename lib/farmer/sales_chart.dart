import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategorySalesPieChart extends StatelessWidget {
  final Map<String, int> categorySales;

  CategorySalesPieChart({required this.categorySales});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: categorySales.entries.map((entry) {
          return PieChartSectionData(
            color: _getCategoryColor(entry.key),
            value: entry.value.toDouble(),
            title: "${entry.key}\n${entry.value}",
            radius: 80,
            titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }).toList(),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "Fruits":
        return Colors.red;
      case "Vegetables":
        return Colors.green;
      case "Grains":
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }

}
