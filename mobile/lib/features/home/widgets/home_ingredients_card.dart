import 'package:flutter/material.dart';

class HomeIngredientsCard extends StatelessWidget {
  final VoidCallback? onRefresh; // 1. Add this field

  const HomeIngredientsCard({super.key, this.onRefresh}); // 2. Update constructor

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        // 3. Make this async and wait for the result
        onTap: () async {
          final result = await Navigator.pushNamed(context, '/ingredients/list');
          
          // 4. Trigger refresh if a log was successful
          if (result == true && onRefresh != null) {
            onRefresh!();
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding( // Added padding for better UI
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 229, 255, 246),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.egg_rounded, size: 32, color: Colors.green),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ingredients',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Browse delicious ingredients',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    )
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey)
            ],
          ),
        ),
      ),
    );
  }
}