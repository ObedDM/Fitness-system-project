import 'package:flutter/material.dart';

class ConsumptionSummaryWidget extends StatelessWidget {
  final Map<String, dynamic>? data;
  final int days;

  const ConsumptionSummaryWidget({super.key, this.data, required this.days});

  @override
  Widget build(BuildContext context) {
    if (data == null || data!['data'].isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text("No logs found for this period.")
        )
      );
    }

    double totalCals = 0, totalProt = 0, totalCarbs = 0, totalFat = 0;
    int daysWithData = 0;

    for (var dayData in data!['data']) {
      if ((dayData['logs'] as List).isNotEmpty) {
        totalCals += dayData['total_calories'];
        totalProt += dayData['total_protein'];
        totalCarbs += dayData['total_carbohydrates'];
        totalFat += dayData['total_fat'];
        daysWithData++;
      }
    }

    final avgCals = totalCals;
    final avgProt = totalProt;
    final avgCarbs = totalCarbs;
    final avgFat = totalFat;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ✅ Muestra cuántos días tienen datos sobre el total
            Text(
              days == 1
                ? "Today's Intake"
                : "$days days intake",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),

            const SizedBox(height: 16),

            Text(
              "${avgCals.toStringAsFixed(0)} kcal",
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
            ),

            const Divider(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacroItem("Protein", avgProt,  "g", Colors.blue),
                _buildMacroItem("Carbs",   avgCarbs, "g", Colors.orange),
                _buildMacroItem("Fat",     avgFat,   "g", Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroItem(String label, dynamic value, String unit, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        Text("${value.toStringAsFixed(1)}$unit", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
