import 'package:flutter/material.dart';

class CustomKeyboard extends StatelessWidget {
  final TextEditingController controller;
  final bool capsLock;
  final VoidCallback onCapsLock;

  const CustomKeyboard({
    super.key,
    required this.controller,
    required this.capsLock,
    required this.onCapsLock,
  });

  void _insert(String char) {
    final text = controller.text;
    final selection = controller.selection;
    final start = selection.start < 0 ? text.length : selection.start;
    final end = selection.end < 0 ? text.length : selection.end;
    final newText = text.replaceRange(start, end, char);
    final newOffset = start + char.length;
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }

  void _backspace() {
    final text = controller.text;
    final selection = controller.selection;
    if (text.isEmpty) return;
    final start = selection.start < 0 ? text.length : selection.start;
    final end = selection.end < 0 ? text.length : selection.end;
    late String newText;
    late int newOffset;
    if (start != end) {
      newText = text.replaceRange(start, end, '');
      newOffset = start;
    } else if (start > 0) {
      newText = text.replaceRange(start - 1, start, '');
      newOffset = start - 1;
    } else {
      return;
    }
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }

  // Estilo compartido para todos los botones
  static final _keyStyle = ElevatedButton.styleFrom(
    padding: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6), // ← menos redondeado
    ),
    elevation: 1,
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
  );

  @override
  Widget build(BuildContext context) {
    final rows = [
      ['q','w','e','r','t','y','u','i','o','p'],
      ['a','s','d','f','g','h','j','k','l'],
      ['z','x','c','v','b','n','m'],
    ];
    final numbers = ['1','2','3','4','5','6','7','8','9','0'];

    return Container(
      color: Colors.grey.shade300,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(numbers),
          const SizedBox(height: 4),
          ...rows.map((row) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _buildRow(
              capsLock ? row.map((k) => k.toUpperCase()).toList() : row,
            ),
          )),
          // Fila de acciones
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: onCapsLock,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      backgroundColor: capsLock ? Colors.blue.shade300 : null,
                      elevation: 1,
                    ),
                    child: Icon(
                      capsLock
                          ? Icons.keyboard_capslock
                          : Icons.keyboard_capslock_outlined,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: 5,
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => _insert(' '),
                    style: _keyStyle,
                    child: const Text('Space'),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _backspace,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 1,
                    ),
                    child: const Icon(Icons.backspace_outlined, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      children: keys.map((k) => Expanded( // ← Expanded en lugar de SizedBox fijo
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: () => _insert(k),
              style: _keyStyle,
              child: Text(k),
            ),
          ),
        ),
      )).toList(),
    );
  }
}
