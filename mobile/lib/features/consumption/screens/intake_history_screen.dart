import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';

class IntakeHistoryScreen extends StatelessWidget {
  final List<dynamic> logs;
  final DateTime date;

  const IntakeHistoryScreen({super.key, required this.logs, required this.date});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Log: ${DateFormat('MMM dd, yyyy').format(date)}"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: logs.isEmpty
          ? const Center(child: Text("No entries for this day"))
          : ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.stylus,
                  PointerDeviceKind.trackpad,
                },
              ),
              child: ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  final time = DateFormat('HH:mm').format(DateTime.parse(log['log_timestamp']));

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showLogDetails(context, log),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.blue, size: 28),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    log['item_name'] ?? 'Unknown Item',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "$time • ${log['amount']} ${log['unit']}",
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${log['calories'].toStringAsFixed(1)} kcal",
                                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "P: ${log['protein'].toStringAsFixed(1)}g | C: ${log['carbohydrates'].toStringAsFixed(1)}g",
                                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  void _showLogDetails(BuildContext context, Map<String, dynamic> log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.stylus,
                PointerDeviceKind.trackpad,
              },
            ),
            child: ListView(
              controller: controller,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Text(log['item_name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text("Consumed: ${log['amount']} ${log['unit']}"),
                const Divider(height: 32),

                const Text("Macronutrients", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildNutrientRow("Calories", log['calories'], "kcal", Colors.orange),
                _buildNutrientRow("Protein", log['protein'], "g", Colors.blue),
                _buildNutrientRow("Carbohydrates", log['carbohydrates'], "g", Colors.green),
                _buildNutrientRow("Fat", log['fat'], "g", Colors.red),

                const SizedBox(height: 32),
                const Text("Micronutrients", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                if (log['micronutrients'] != null && (log['micronutrients'] as Map).isNotEmpty)
                  ...(log['micronutrients'] as Map<String, dynamic>).entries.map((e) {
                    return _buildNutrientRow(e.key, e.value['quantity'], e.value['unit'], Colors.grey[700]!);
                  })
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "No micronutrient data recorded for this item.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildNutrientRow(String name, dynamic value, String unit, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: TextStyle(color: Colors.grey[800], fontSize: 16)),
          Text(
            "${(value as num).toStringAsFixed(2)} $unit",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
          ),
        ],
      ),
    );
  }
}
