import 'package:flutter/material.dart';

class DishCard extends StatelessWidget {
  final Map<String, dynamic> dish;
  final VoidCallback? onTap;

  const DishCard({
    super.key,
    required this.dish,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ??
          () => Navigator.pushNamed(
                context,
                '/dish/info',
                arguments: dish['dish_id'],
              ),
      borderRadius: BorderRadius.circular(16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              height: 70,
              width: 70,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 235, 255, 229),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Icon(
                Icons.restaurant_menu_outlined,
                size: 40,
                color: Colors.greenAccent,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${dish["name"] ?? "-"}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    // si no tienes kcal del plato aún, muestra categoría y porciones
                    '${dish["category"] ?? "-"} · '
                    '${dish["servings"] ?? "-"} servings',
                    style: const TextStyle(color: Colors.orange),
                  ),
                ],
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                'by: ${dish["created_by_username"] ?? "unknown"}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
