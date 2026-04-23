import 'package:flutter/material.dart';
import 'package:naturats/model/category_class.dart';
import 'package:naturats/theme/app_colors.dart';

class FilterCategory extends StatelessWidget {
  final VoidCallback onTap;

  final bool isSelected;

  final Category category;

  const FilterCategory({
    super.key,
    required this.onTap,
    required this.isSelected,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.buttomVerde : AppColors.branco,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.buttomVerde
                : AppColors.borderCinza.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.buttomVerde.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(4, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          category.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? AppColors.branco : AppColors.preto,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
