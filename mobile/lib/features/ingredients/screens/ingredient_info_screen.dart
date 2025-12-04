import 'package:flutter/material.dart';
import 'package:mobile/features/ingredients/widgets/ingredient_additional_info.dart';
import 'package:mobile/features/ingredients/widgets/ingredient_macros_card.dart';
import 'package:mobile/services/auth_service.dart';

class IngredientInfoScreen extends StatefulWidget {
  const IngredientInfoScreen({super.key});

  @override
  State<IngredientInfoScreen> createState() => _IngredientInfoScreenState();
}

class _IngredientInfoScreenState extends State<IngredientInfoScreen> {
  final _authService = AuthService();
  Map<String, dynamic>? _ingredientInfoData;
  bool _isLoading = true;

    @override
    void didChangeDependencies() {
      super.didChangeDependencies();
      _loadIngredientInfo();
    }

    Future<void> _loadIngredientInfo() async {
    final ingredientId = ModalRoute.of(context)?.settings.arguments as String?;
    if (ingredientId != null) {
      final data = await _authService.getIngredientInfo(ingredientId);
      setState(() {
        _ingredientInfoData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ingredient Info')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _ingredientInfoData == null
              ? Center(child: Text('Error loading ingredient'))
              : Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      Text(
                        _ingredientInfoData!['name'] ?? '-',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'by: ${_ingredientInfoData!['created_by_username'] ?? '-'}',
                        style: const TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 24),
                      
                      // MacroNutrients
                      const Text(
                        'Macronutrients (per 100g)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: IngredientMacrosCard(
                              text: 'Calories',
                              value: '${_ingredientInfoData!['calories'] ?? '-'}',
                              unit: 'kcal',
                              color: Colors.orange,
                            ),
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: IngredientMacrosCard(
                              text: 'Protein',
                              value: '${_ingredientInfoData!['protein'] ?? '-'}',
                              unit: 'g',
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: IngredientMacrosCard(
                              text: 'Fat',
                              value: '${_ingredientInfoData!['fat'] ?? '-'}',
                              unit: 'g',
                              color: Colors.red,
                            ),
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: IngredientMacrosCard(
                              text: 'Carbs',
                              value: '${_ingredientInfoData!['carbohydrates'] ?? '-'}',
                              unit: 'g',
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      IngredientAdditionalInfo(
                        text: 'Glycemic Index',
                        value: '${_ingredientInfoData!['glycemic_index'] ?? '-'}',
                      ),

                      const SizedBox(height: 24),

                      // Composition
                      const Text(
                        'Additional composition',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 12),

                      IngredientAdditionalInfo(
                        text: 'Water',
                        value: '${_ingredientInfoData!['water'] ?? '-'} g',
                      ),

                      const SizedBox(height: 24),

                      // Micronutrientes
                      const Text(
                        'Composition',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Builder(
                        builder: (context) {
                          final micros = _ingredientInfoData!['micronutrients'] as Map<String, dynamic>?;

                          if (micros == null || micros.isEmpty) {
                            return const Text('No micronutrients data');
                          }
                        
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: micros.entries.map((entry) {
                                  final name = entry.key;
                                  final data = entry.value;
                                  final quantity = data['quantity'] ?? '-';
                                  final unit = data['unit'] ?? '';

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(name),
                                        Text(
                                          '$quantity $unit',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
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