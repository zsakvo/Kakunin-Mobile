import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:kakunin/utils/i18n.dart';

void _openDialog(
    BuildContext context, String title, Widget content, void Function()? onPositive, void Function()? onNegative) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (_) {
      return AlertDialog(
        contentPadding: const EdgeInsets.all(6.0),
        title: Text(title),
        content: content,
        actions: [
          TextButton(onPressed: onNegative, child: Text("Cancel".i18n)),
          FilledButton(onPressed: onPositive, child: Text("OK".i18n))
        ],
      );
    },
  );
}

void openMainColorPicker(BuildContext context, Color colorSeed, Function(ColorSwatch<dynamic>?)? onMainColorChange,
    void Function()? onPositive, void Function()? onNegative) async {
  _openDialog(
      context,
      "Color picker".i18n,
      MaterialColorPicker(
          elevation: 0,
          spacing: 12,
          selectedColor: colorSeed,
          allowShades: false,
          onMainColorChange: onMainColorChange),
      onPositive,
      onNegative);
}
