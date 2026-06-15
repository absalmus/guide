import 'package:flutter/material.dart';
import 'package:stitch_smart_church_guide/core/constants/app_colors.dart';

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    this.hint = 'ابحث عن كنيسة، قداس، أو اجتماع...',
    this.onTap,
    this.readOnly = true,
    this.controller,
    this.onChanged,
  });

  final String hint;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search, color: AppColors.copticBurgundy),
          suffixIcon: IconButton(
            icon: const Icon(Icons.mic, color: AppColors.copticGold),
            onPressed: onTap,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
        ),
      ),
    );
  }
}
