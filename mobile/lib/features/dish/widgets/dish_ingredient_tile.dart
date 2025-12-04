import 'package:flutter/material.dart';
import 'package:mobile/services/auth_service.dart';

class DishIngredientTile extends StatelessWidget {
  final Map<String, dynamic> ingredient;

  const DishIngredientTile({super.key, required this.ingredient});

  @override
  Widget build(BuildContext context) {
    final double amount = (ingredient["amount"] ?? 0).toDouble();
    final String unit = ingredient["unit"] ?? "";
    final String name = ingredient["name"] ?? "-";
    final String ingredientId = ingredient["ingredient_id"] ?? "";

    return ExpansionTile(
      leading: const Icon(Icons.restaurant_outlined, color: Colors.green),
      title: Text('$amount $unit'),
      subtitle: Text(name),
      children: [
        FutureBuilder<Map<String, dynamic>?>(
          future: AuthService().getIngredientInfo(ingredientId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            final data = snapshot.data!;
            final factor = amount / 100.0;

            final cals = ((data['calories'] ?? 0) * factor).toStringAsFixed(1);
            final prot = ((data['protein'] ?? 0) * factor).toStringAsFixed(1);
            final fats = ((data['fat'] ?? 0) * factor).toStringAsFixed(1);
            final carb = ((data['carbohydrates'] ?? 0) * factor).toStringAsFixed(1);
            final water = data['water'] != null 
                ? ((data['water'] * factor).toStringAsFixed(1)) 
                : '-';
            final gi = data['glycemic_index'] ?? '-';

            final micros = data['micronutrients'] as Map<String, dynamic>?;

            return Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 300.0, top: 8.0, bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Calories: $cals kcal', style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('Protein: $prot g'),
                  Text('Fat: $fats g'),
                  Text('Carbs: $carb g'),
                  Text('Water: $water g'),
                  Text('Glycemic Index: $gi'),
                  
                  if (micros != null && micros.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text('Micronutrients:', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    ...micros.entries.map((micro) {
                      final qty = ((micro.value['quantity'] ?? 0) * factor).toStringAsFixed(2);
                      final unit = micro.value['unit'] ?? '';
                      return Text('${micro.key}: $qty $unit');
                    }).toList(),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
