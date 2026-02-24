import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../utils/scale_reader.dart';
import '../../../widgets/custom_keyboard.dart';

class LogFoodModal extends StatefulWidget {
  final String id;
  final String name;
  final bool isDish;

  const LogFoodModal({super.key, required this.id, required this.name, required this.isDish});

  @override
  State<LogFoodModal> createState() => _LogFoodModalState();
}

class _LogFoodModalState extends State<LogFoodModal> {
  final _amountController = TextEditingController();
  String _selectedMeal = 'Breakfast';
  final _scaleService = ScaleService();
  final _authService = AuthService();
  bool _isReadingScale = false;

  bool _showKeyboard = false;
  bool _capsLock = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _readFromScale() async {
    setState(() => _isReadingScale = true);
    try {
      final weight = await _scaleService.readWeight();
      if (mounted) {
        if (weight != null) {
          setState(() => _amountController.text = weight);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se detectó peso en la báscula')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isReadingScale = false);
    }
  }

  Future<void> _calculateServingsFromWeight() async {
    setState(() => _isReadingScale = true);
    try {
      final dishData = await _authService.getDishInfo(widget.id);
      if (dishData == null) throw Exception('No se pudo obtener info del platillo');

      final ingredients = dishData['ingredients'] as List<dynamic>?;
      if (ingredients == null || ingredients.isEmpty) throw Exception('El platillo no tiene ingredientes');

      double totalWeight = 0.0;
      for (var ingredient in ingredients) {
        totalWeight += (ingredient['amount'] as num).toDouble();
      }
      if (totalWeight <= 0) throw Exception('Peso total inválido');

      final totalServings = (dishData['servings'] as num?)?.toDouble() ?? 1.0;
      final weightPerServing = totalWeight / totalServings;
      final weight = await _scaleService.readWeight();
      if (weight == null) throw Exception('No se detectó peso en la báscula');

      final servings = double.parse(weight) / weightPerServing;
      if (mounted) setState(() => _amountController.text = servings.toStringAsFixed(2));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isReadingScale = false);
    }
  }

  Future<void> _submitLog() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    final payload = {
      'ingredient_id': widget.isDish ? null : widget.id,
      'dish_id': widget.isDish ? widget.id : null,
      'amount': amount,
      'meal_type': _selectedMeal.toLowerCase(),
      'log_timestamp': DateTime.now().toUtc().toIso8601String(),
    };

    final success = await _authService.logConsumption(payload);
    if (mounted) {
      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error 400: Check Payload')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Contenido del modal ──
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Log ${widget.name}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showKeyboard = true),
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: widget.isDish ? "Servings" : "Grams (g)",
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isReadingScale
                        ? null
                        : (widget.isDish ? _calculateServingsFromWeight : _readFromScale),
                    icon: _isReadingScale
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(widget.isDish ? Icons.calculate : Icons.scale),
                    tooltip: widget.isDish ? 'Calcular' : 'Pesar',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                      foregroundColor: Colors.blue,
                    ),
                  ),

                  IconButton(
                    onPressed: _isReadingScale ? null : () async {
                      await _scaleService.tare();
                      if (widget.isDish) {
                        await _calculateServingsFromWeight();
                      } else {
                        await _readFromScale();
                      }
                    },
                    icon: const Icon(Icons.exposure_zero),
                    tooltip: 'Tara',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.orange.shade50,
                      foregroundColor: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              DropdownButton<String>(
                value: _selectedMeal,
                isExpanded: true,
                items: ['Breakfast', 'Lunch', 'Dinner', 'Snack']
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedMeal = v!),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _submitLog,
                child: const Text("Confirm Entry"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),

        // ── Teclado virtual ──
        if (_showKeyboard) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.keyboard_hide),
                onPressed: () => setState(() => _showKeyboard = false),
              ),
            ],
          ),
          CustomKeyboard(
            controller: _amountController,
            capsLock: _capsLock,
            onCapsLock: () => setState(() => _capsLock = !_capsLock),
          ),
        ]
      ],
    );
  }
}
