import 'package:flutter/material.dart';
import 'package:naturats/model/category_class.dart';
import 'package:naturats/theme/app_colors.dart';

class CategoryTag extends StatelessWidget {
  final Category category;

  const CategoryTag({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6, top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: category.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: category.color.withValues(alpha: 0.8),
          width: 1.5,
        ),
      ),
      child: Text(
        category.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.branco,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
