import 'package:flutter/material.dart';
import 'package:virtual_keyboard_multi_language/virtual_keyboard_multi_language.dart';

class KeyboardUtils {
  static Widget wrapField({
    required TextEditingController controller,
    required Widget textField,
    required Function(TextEditingController) onTap,
  }) {
    return GestureDetector(
      onTap: () => onTap(controller),
      child: AbsorbPointer(child: textField),
    );
  }

  static Widget buildKeyboard({
    required TextEditingController? activeController,
    required bool capsLock,
    required VoidCallback onToggleCaps,
    required VoidCallback onHide,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(Icons.keyboard_hide),
              onPressed: onHide,
            ),
          ],
        ),
        VirtualKeyboard(
          height: 220,
          type: VirtualKeyboardType.Alphanumeric,
          textController: activeController,
          defaultLayouts: [VirtualKeyboardDefaultLayouts.English],
          postKeyPress: (key) {
            if (key.keyType == VirtualKeyboardKeyType.Action &&
                key.action == VirtualKeyboardKeyAction.Shift) {
              onToggleCaps();
            }
          },
        ),
      ],
    );
  }
}
