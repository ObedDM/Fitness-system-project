// Archivo: lib/features/ingredients/widgets/micronutrient_modal.dart
import 'package:flutter/material.dart';
import 'package:mobile/features/ingredients/widgets/micronutrient_card.dart';

class MicronutrientModal extends StatefulWidget {
  final List<Map<String, dynamic>> micronutrients;
  final Function(int) onDelete;
  
  const MicronutrientModal({super.key, required this.micronutrients, required this.onDelete});

  @override
  State<MicronutrientModal> createState() => _MicronutrientModalState();
}

class _MicronutrientModalState extends State<MicronutrientModal> {
  
  void _deleteMicronutrient(int index) {
    setState(() {
      widget.onDelete(index);
      setState(() {});
    });
  }

  void _showAddMicronutrientDialog() {
    String? selectedMicronutrient;
    final quantityController = TextEditingController();
    
    final micronutrients = ['Calcium', 'Iron', 'Magnesium', 'Potassium', 'Zinc', 'Vitamin A', 'Vitamin C', 'Vitamin D'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Agregar Micronutriente'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedMicronutrient,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: micronutrients.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
                    onChanged: (value) => setDialogState(() => selectedMicronutrient = value),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Quantity',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Text('mg', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            // Cancelar
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),

            // Guardar
            ElevatedButton(
              onPressed: () {
                if (selectedMicronutrient != null && quantityController.text.isNotEmpty) {
                  setState(() {
                    widget.micronutrients.add({
                      'name': selectedMicronutrient,
                      'quantity': double.tryParse(quantityController.text) ?? 0,
                      'unit': 'mg',
                      'category': 'Mineral',
                    });
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('Guardar'),
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Micronutrientes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          
          Divider(),
          
          Expanded(
            child: ListView.builder(
              itemCount: widget.micronutrients.length,
              itemBuilder: (context, index) {
                return MicroNutrientCard(
                  micronutrient: widget.micronutrients[index],
                  onDelete: () => _deleteMicronutrient(index),
                );
              },
            ),
          ),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showAddMicronutrientDialog,
              child: Text('Agregar Micronutriente'),
            ),
          ),
        ],
      ),
    );
  }
}
