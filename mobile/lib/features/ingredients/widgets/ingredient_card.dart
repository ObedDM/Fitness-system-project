import 'package:flutter/material.dart';

class IngredientCard extends StatelessWidget {
  final Map<String, dynamic> ingredient;
  final VoidCallback? onTap;

  const IngredientCard({super.key, required this.ingredient, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(
        context, 
        '/ingredient/info',
        arguments: ingredient['ingredient_id'], // <-- Asegúrate que este campo existe
      ),
      borderRadius: BorderRadius.circular(16),
      //splashColor: Colors.orange.withAlpha((1 * 255).toInt()),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [

            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 235, 255, 229),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Icon(
                Icons.image_outlined,
                size: 40,
                color: Colors.greenAccent
              )
            ),

            // blank space
            SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "${ingredient["name"] ?? "-"}",
                    style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                  ),

                  Text(
                    "${ingredient["calories"] ?? "-"} kcal",
                    style: TextStyle(color: Colors.orange),
                  ),
                ],
              ),   
            ),

            Spacer(),

            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                "by: ${ingredient["created_by_username"] ?? "unknown"}",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}