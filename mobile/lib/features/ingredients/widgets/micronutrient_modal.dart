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
              onPressed: () {},
              child: Text('Agregar Micronutriente'),
            ),
          ),
        ],
      ),
    );
  }
}
