import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:mobile/features/dish/widgets/dish_ingredient_tile.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/features/consumption/widgets/log_food_modal.dart';

class DishInfoScreen extends StatefulWidget {
  const DishInfoScreen({super.key});

  @override
  State<DishInfoScreen> createState() => _DishInfoScreenState();
}

class _DishInfoScreenState extends State<DishInfoScreen> {
  final _authService = AuthService();
  Map<String, dynamic>? _dishInfoData;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadDishInfo();
  }

  Future<void> _loadDishInfo() async {
    final dishId = ModalRoute.of(context)?.settings.arguments as String?;
    if (dishId != null) {
      final data = await _authService.getDishInfo(dishId);
      if (mounted) {
        setState(() {
          _dishInfoData = data;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dish info')),
      floatingActionButton: _isLoading || _dishInfoData == null
          ? null
          : FloatingActionButton(
              onPressed: () async {
                final result = await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => LogFoodModal(
                    id: _dishInfoData!['dish_id']?.toString() ?? '',
                    name: _dishInfoData!['name']?.toString() ?? 'Unknown Dish',
                    isDish: true,
                  ),
                );
                if (result == true && mounted) Navigator.pop(context, true);
              },
              child: const Icon(Icons.add),
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dishInfoData == null
              ? const Center(child: Text('Error loading Dish'))
              : ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.stylus,
                      PointerDeviceKind.trackpad,
                    },
                  ),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: _dishInfoData!['dish_id'] != null
                              ? Image.network(
                                  'http://192.168.100.55:8000/dish/${_dishInfoData!['dish_id']}/image',
                                  width: 180,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Image.asset(
                                    'assets/images/placeholder.jpg',
                                    width: 180,
                                    height: 180,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Image.asset(
                                  'assets/images/placeholder.jpg',
                                  width: 180,
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      Text(
                        _dishInfoData!['name'] ?? '-',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_dishInfoData!["category"] ?? "-"} · ${_dishInfoData!["servings"] ?? "-"} servings',
                        style: const TextStyle(color: Colors.orange),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'by: ${_dishInfoData!["created_by_username"] ?? "unknown"}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),

                      if (_dishInfoData!['description'] != null &&
                          _dishInfoData!['description'].toString().isNotEmpty) ...[
                        const Text('Description', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(_dishInfoData!['description']),
                        const SizedBox(height: 16),
                      ],

                      const Text('Ingredients', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),

                      Builder(
                        builder: (context) {
                          final ingredients = _dishInfoData!['ingredients'] as List<dynamic>? ?? [];
                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              children: ingredients.isEmpty
                                  ? const [ListTile(title: Text('No ingredients'))]
                                  : ingredients
                                      .map((ing) => DishIngredientTile(ingredient: ing))
                                      .toList(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
    );
  }
}
