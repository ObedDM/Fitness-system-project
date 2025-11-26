import 'package:flutter/material.dart';

class MicroNutrientCard extends StatelessWidget {
  final Map<String, dynamic> micronutrient;
  final VoidCallback onDelete;
  final bool compact;

  const MicroNutrientCard({super.key, required this.micronutrient, required this.onDelete, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: compact ? 0 : 1,
      color: Colors.white,
      margin: compact ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        dense: compact,
        visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
        contentPadding: compact
          ? const EdgeInsets.symmetric(horizontal: 8)
          : const EdgeInsets.symmetric(horizontal: 16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.eco, color: Colors.green, size: compact ? 20 : 24),
        ),
        title: Text(
          micronutrient['name'] ?? '',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: compact ? 13 : 16, // Texto escalable
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          "${micronutrient['quantity']} ${micronutrient['unit']}",
          style: TextStyle(fontSize: compact ? 12 : 14),
        ),
        trailing: compact 
            ? null 
            : IconButton(
                icon: const Icon(Icons.delete, color: Colors.grey),
                onPressed: onDelete,
              ),
      ),
    );
  }
}