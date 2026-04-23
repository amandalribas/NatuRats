import 'package:flutter/material.dart';
import 'package:naturats/model/category_class.dart';
import 'package:naturats/theme/app_colors.dart';

enum SubCategoryModel implements Category {
  agua,
  energia,
  residuos,
  mobilidade,
  biodiversidade;

  @override
  String get label {
    switch (this) {
      case SubCategoryModel.agua:
        return "Água";
      case SubCategoryModel.energia:
        return "Energia";
      case SubCategoryModel.residuos:
        return "Resíduos";
      case SubCategoryModel.mobilidade:
        return "Mobilidade";
      case SubCategoryModel.biodiversidade:
        return "Biodiversidade";
    }
  }

  @override
  Color get color {
    switch (this) {
      case SubCategoryModel.agua:
        return AppColors.agua;
      case SubCategoryModel.energia:
        return AppColors.energia;
      case SubCategoryModel.residuos:
        return AppColors.residuos;
      case SubCategoryModel.mobilidade:
        return AppColors.mobilidade;
      case SubCategoryModel.biodiversidade:
        return AppColors.biodiversidade;
    }
  }

  IconData get icon {
    switch (this) {
      case SubCategoryModel.agua:
        return Icons.water_drop_outlined;
      case SubCategoryModel.energia:
        return Icons.bolt;
      case SubCategoryModel.residuos:
        return Icons.recycling;
      case SubCategoryModel.mobilidade:
        return Icons.directions_bike;
      case SubCategoryModel.biodiversidade:
        return Icons.park_outlined;
    }
  }
}
