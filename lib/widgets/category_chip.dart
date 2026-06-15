import 'package:flutter/material.dart';
import 'package:stitch_smart_church_guide/core/constants/app_colors.dart';
import 'package:stitch_smart_church_guide/core/constants/enums.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final AgeCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(category.label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.copticBurgundy.withValues(alpha: 0.15),
      checkmarkColor: AppColors.copticBurgundy,
      labelStyle: TextStyle(
        color: selected ? AppColors.copticBurgundy : null,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }
}

IconData categoryIcon(AgeCategory category) {
  return switch (category) {
    AgeCategory.nursery => Icons.child_care,
    AgeCategory.primary => Icons.school,
    AgeCategory.preparatory => Icons.menu_book,
    AgeCategory.secondary => Icons.auto_stories,
    AgeCategory.university => Icons.school_outlined,
    AgeCategory.youth => Icons.groups,
    AgeCategory.families => Icons.family_restroom,
    AgeCategory.servants => Icons.volunteer_activism,
  };
}
