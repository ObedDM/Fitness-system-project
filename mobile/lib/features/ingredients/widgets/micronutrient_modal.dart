// Archivo: lib/features/ingredients/widgets/micronutrient_modal.dart
import 'package:flutter/material.dart';

class MicronutrientModal extends StatelessWidget {
  const MicronutrientModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400, // Una altura fija para probar
      width: double.infinity,
      color: Colors.white, // Fondo blanco
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.construction, size: 50, color: Colors.orange),
            SizedBox(height: 20),
            Text(
              "¡Aquí va el Modal!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text("Si ves esto, la conexión funciona."),
          ],
        ),
      ),
    );
  }
}