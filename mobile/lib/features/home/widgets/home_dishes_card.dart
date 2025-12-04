import 'package:flutter/material.dart';

class HomeDishesCard extends StatelessWidget {
  const HomeDishesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/dishes/list'),
        borderRadius: BorderRadius.circular(16),

        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 229, 255, 246),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.restaurant_menu_rounded, size: 32, color: Colors.green,),
            ),

            SizedBox(width: 16),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dishes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    'Search for your favorite Dishes',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey
                    ),
                  )
                ],
              ),
            ),

            const Icon(Icons.chevron_right, color: Colors.grey)
          ],
        ),
      ),
    );
  }
}