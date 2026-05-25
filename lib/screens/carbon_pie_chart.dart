import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/carbon_summary_model.dart';

class CarbonPieChart extends StatelessWidget {
  final List<ActivityLog> history;

  const CarbonPieChart({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    // 1. Tally up emissions by category name
    Map<String, double> categoryTotals = {};
    double totalAll = 0.0;

    for (var log in history) {
      categoryTotals[log.categoryName] = (categoryTotals[log.categoryName] ?? 0.0) + log.calculatedCo2;
      totalAll += log.calculatedCo2;
    }

    // If there is no data yet, show a clean placeholder layout
    if (totalAll == 0.0) {
      return const Center(
        child: Text('No logging metrics recorded to populate charts yet.', 
          style: TextStyle(color: Colors.grey, fontSize: 13)),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: 40,
              sections: categoryTotals.entries.map((entry) {
                final percentage = (entry.value / totalAll) * 100;
                
                return PieChartSectionData(
                  color: _getCategoryColor(entry.key),
                  value: entry.value,
                  title: '${percentage.toStringAsFixed(0)}%',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 2. Generate dynamic Legend row markers
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: categoryTotals.keys.map((catName) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(catName),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  catName.replaceAll('_', ' '),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            );
          }).toList(),
        )
      ],
    );
  }

  Color _getCategoryColor(String name) {
    if (name.contains('VEHICLE')) return Colors.orange;
    if (name.contains('ELECTRICITY')) return Colors.amber;
    if (name.contains('FLIGHT')) return Colors.blue;
    return Colors.red;
  }
}