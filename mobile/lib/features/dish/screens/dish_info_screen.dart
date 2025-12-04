import 'package:flutter/material.dart';
import 'package:mobile/features/dish/widgets/dish_ingredient_tile.dart';
import 'package:mobile/services/auth_service.dart';

class DishInfoScreen extends StatefulWidget {
  const DishInfoScreen({super.key});

  @override
  State<DishInfoScreen> createState() => _DishInfoScreenState();
}

class _DishInfoScreenState extends State<DishInfoScreen> {
  final _authService = AuthService();
  Map<String, dynamic>? _DishInfoData;
  bool _isLoading = true;

    @override
    void didChangeDependencies() {
      super.didChangeDependencies();
      _loadDishInfo();
    }

    Future<void> _loadDishInfo() async {
    final DishId = ModalRoute.of(context)?.settings.arguments as String?;
    if (DishId != null) {
      final data = await _authService.getDishInfo(DishId);
      setState(() {
        _DishInfoData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dish info')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _DishInfoData == null
              ? const Center(child: Text('Error loading Dish'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    children: [

                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: _DishInfoData!['dish_id'] != null
                            ? Image.network(
                                'http://localhost:8000/dish/${_DishInfoData!['dish_id']}/image',
                                width: 180,
                                height: 180,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // placeholder para cuando no haya imagen
                                  return Image.asset(
                                    'assets/images/placeholder.jpg',
                                    width: 180,
                                    height: 180,
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : Image.asset(
                                'assets/images/placeholder.jpg',
                                width: 180,
                                height: 180,
                                fit: BoxFit.cover,
                              ),
                        )
                      ),

                      const SizedBox(height: 16),
                      // Nombre
                      Text(
                        _DishInfoData!['name'] ?? '-',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // categoría + servings
                      Text(
                        '${_DishInfoData!["category"] ?? "-"} · '
                        '${_DishInfoData!["servings"] ?? "-"} servings',
                        style: const TextStyle(color: Colors.orange),
                      ),

                      const SizedBox(height: 4),

                      // creador
                      Text(
                        'by: ${_DishInfoData!["created_by_username"] ?? "unknown"}',
                        style: const TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 16),

                      // Descripción
                      if (_DishInfoData!['description'] != null &&
                          _DishInfoData!['description'].toString().isNotEmpty) ...[
                        const Text(
                          'Description',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(_DishInfoData!['description']),
                        const SizedBox(height: 16),
                      ],

                      // Ingredientes
                      const Text(
                        'Ingredients',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),

                      Builder(
                        builder: (context) {
                          final ingredients = _DishInfoData!['ingredients'] as List<dynamic>? ?? [];

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: ingredients.isEmpty
                                  ? const [
                                      ListTile(title: Text('No ingredients')),
                                    ]
                                  : ingredients.map((ing) => DishIngredientTile(ingredient: ing)).toList(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}