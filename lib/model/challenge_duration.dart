import 'package:flutter/material.dart';
import 'package:naturats/model/category.dart';
import 'package:naturats/theme/app_colors.dart';

enum ChallengeDuration implements Category {
  daily,
  weekly,
  monthly;

  @override
  String get label {
    switch (this) {
      case ChallengeDuration.daily:
        return "Diário";
      case ChallengeDuration.weekly:
        return "Semanal";
      case ChallengeDuration.monthly:
        return "Mensal";
    }
  }

  @override
  Color get color {
    switch (this) {
      case ChallengeDuration.daily:
        return AppColors.diarioRosa;
      case ChallengeDuration.weekly:
        return AppColors.semanalRoxo;
      case ChallengeDuration.monthly:
        return AppColors.mensalAmarelo;
    }
  }

  factory ChallengeDuration.fromMap(String duration) {
    switch (duration) {
      case "daily":
        return ChallengeDuration.daily;
      case "weekly":
        return ChallengeDuration.weekly;
      case "monthly":
        return ChallengeDuration.monthly;
      default:
        throw ArgumentError.value(
          duration,
          'duration',
          'Invalid challenge duration',
        );
    }
  }
}
