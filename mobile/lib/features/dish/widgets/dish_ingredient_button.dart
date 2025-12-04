import 'package:flutter/material.dart';
import 'dish_ingredient_item_card.dart';

class DishIngredientButton extends StatelessWidget {
  final List<Map<String, dynamic>> ingredients;
  final VoidCallback onTap;

  const DishIngredientButton({
    super.key,
    required this.ingredients,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.restaurant_menu, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'Ingredients (${ingredients.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
            if (ingredients.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...ingredients.take(3).map((ingredient) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: DishIngredientItemCard(
                    ingredient: ingredient,
                    onDelete: () {},
                    compact: true,
                  ),
                );
              }).toList(),
              if (ingredients.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+${ingredients.length - 3} more',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
