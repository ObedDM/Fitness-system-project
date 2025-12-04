import 'package:flutter/material.dart';

class DishIngredientItemCard extends StatelessWidget {
  final Map<String, dynamic> ingredient;
  final VoidCallback onDelete;
  final bool compact;

  const DishIngredientItemCard({
    super.key,
    required this.ingredient,
    required this.onDelete,
    this.compact = false,
  });

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
            color: const Color.fromARGB(255, 235, 255, 229),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.restaurant_outlined,
            color: Colors.green,
            size: compact ? 20 : 24,
          ),
        ),
        title: Text(
          ingredient['name'] ?? 'Unknown',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: compact ? 13 : 16,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          "${ingredient['amount']} ${ingredient['unit']}",
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
