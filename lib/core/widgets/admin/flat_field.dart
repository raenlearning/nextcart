import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class FlatField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType; // Diubah menjadi nullable agar fleksibel
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const FlatField({
    super.key,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType, // Menghapus default value hardcode di sini
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isMultiline = maxLines > 1;

    // Menentukan jenis keyboard secara dinamis berdasarkan kondisi parameter
    final effectiveKeyboardType =
        keyboardType ??
        (isMultiline ? TextInputType.multiline : TextInputType.text);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: effectiveKeyboardType,
        textInputAction: isMultiline
            ? TextInputAction.newline
            : TextInputAction.next,
        inputFormatters: inputFormatters,
        style: TextStyle(color: context.colors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: context.colors.textHint, fontSize: 14),
          filled: true,
          fillColor: context.colors.inputFill,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: isMultiline ? 16 : 13,
          ),
          // Memastikan teks petunjuk (hint) rata kiri-atas saat bidang input meluas
          alignLabelWithHint: isMultiline,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: context.colors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: context.colors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
        ),
        validator: validator,
      ),
    );
  }
}
