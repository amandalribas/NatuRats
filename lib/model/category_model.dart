
import 'package:flutter/material.dart';
import 'package:naturats/model/category_class.dart';
import 'package:naturats/theme/app_colors.dart';

enum CategoryModel implements Category {
  diaria,
  semanal,
  mensal;

  @override
  String get label {
    switch (this) {
      case CategoryModel.diaria:
        return "Diária";
      case CategoryModel.semanal:
        return "Semanal";
      case CategoryModel.mensal:
        return "Mensal";
    }
  }

  @override
  Color get color {
    switch (this) {
      case CategoryModel.diaria:
        return AppColors.diarioRosa;
      case CategoryModel.semanal:
        return AppColors.semanalRoxo;
      case CategoryModel.mensal:
        return AppColors.mensalAmarelo;
    }
  }

}
