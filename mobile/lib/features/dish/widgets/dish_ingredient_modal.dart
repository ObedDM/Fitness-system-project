import 'package:flutter/material.dart';
import 'package:mobile/services/auth_service.dart';
import 'dish_ingredient_item_card.dart';

class DishIngredientModal extends StatefulWidget {
  final List<Map<String, dynamic>> ingredients;
  final Function(int) onDelete;
  
  const DishIngredientModal({
    super.key,
    required this.ingredients,
    required this.onDelete,
  });

  @override
  State<DishIngredientModal> createState() => _DishIngredientModalState();
}

class _DishIngredientModalState extends State<DishIngredientModal> { 
  void _deleteIngredient(int index) {
    setState(() {
      widget.onDelete(index);
      setState(() {});
    });
  }

  void _showAddIngredientDialog() async {
    String? selectedIngredientId;
    String? selectedIngredientName;
    final ingredientsList = await AuthService().getIngredientsList();
    final amountController = TextEditingController();
    String selectedUnit = 'g';

    if (!mounted) return;
  
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Ingredient'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownMenu<String>(
                    initialSelection: selectedIngredientId,
                    width: 240,
                    menuHeight: 150,
                    label: const Text('Ingredient'),
                    dropdownMenuEntries: ingredientsList
                        .map<DropdownMenuEntry<String>>((ingredient) {
                      return DropdownMenuEntry<String>(
                        value: ingredient['ingredient_id'],
                        label: ingredient['name'],
                      );
                    }).toList(),
                    onSelected: (value) {
                      setDialogState(() {
                        selectedIngredientId = value;
                        selectedIngredientName = ingredientsList
                            .firstWhere((i) => i['ingredient_id'] == value)['name'];
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: DropdownMenu<String>(
                          initialSelection: selectedUnit,
                          label: const Text('Unit'),
                          dropdownMenuEntries: const [
                            DropdownMenuEntry(value: 'g', label: 'g'),
                            DropdownMenuEntry(value: 'ml', label: 'ml'),
                            DropdownMenuEntry(value: 'oz', label: 'oz'),
                            DropdownMenuEntry(value: 'cup', label: 'cup'),
                          ],
                          onSelected: (value) {
                            setDialogState(() {
                              selectedUnit = value ?? 'g';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedIngredientId != null && amountController.text.isNotEmpty) {
                  setState(() {
                    widget.ingredients.add({
                      'ingredient_id': selectedIngredientId,
                      'name': selectedIngredientName,
                      'amount': double.tryParse(amountController.text) ?? 0,
                      'unit': selectedUnit,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ingredients',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          
          const Divider(),
          
          Expanded(
            child: widget.ingredients.isEmpty
                ? const Center(child: Text('No ingredients added'))
                : ListView.builder(
                    itemCount: widget.ingredients.length,
                    itemBuilder: (context, index) {
                      return DishIngredientItemCard(
                        ingredient: widget.ingredients[index],
                        onDelete: () => _deleteIngredient(index),
                      );
                    },
                  ),
          ),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: _showAddIngredientDialog,
              child: const Text('Add Ingredient'),
            ),
          ),
        ],
      ),
    );
  }
}
