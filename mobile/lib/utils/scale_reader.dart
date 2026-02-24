import 'dart:io';

class ScaleService {
  final String _filePath = '/tmp/scale_weight.txt';
  double _tare = 0.0;

  Future<String?> readWeight() async {
    try {
      final file = File(_filePath);
      if (await file.exists()) {
        String weight = await file.readAsString();
        double value = double.tryParse(weight.trim()) ?? 0.0;
        return (value - _tare).toStringAsFixed(1);
      }
      return null;
    } catch (e) {
      print("Error leyendo báscula: $e");
      return null;
    }
  }

  Future<void> tare() async {
    try {
      final file = File(_filePath);
      if (await file.exists()) {
        String weight = await file.readAsString();
        _tare = double.tryParse(weight.trim()) ?? 0.0;
      }
    } catch (e) {
      print("Error en tara: $e");
    }
  }

  void disconnect() {}
}