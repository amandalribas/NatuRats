import 'package:flutter/material.dart';
import 'package:naturats/model/category.dart';
import 'package:naturats/theme/app_colors.dart';

enum ChallengeType implements Category {
  water,
  energy,
  recycle,
  mobility,
  biodiversity;

  @override
  String get label {
    switch (this) {
      case ChallengeType.water:
        return "Água";
      case ChallengeType.energy:
        return "Energia";
      case ChallengeType.recycle:
        return "Reciclagem";
      case ChallengeType.mobility:
        return "Mobilidade";
      case ChallengeType.biodiversity:
        return "Biodiversidade";
    }
  }

  @override
  Color get color {
    switch (this) {
      case ChallengeType.water:
        return AppColors.agua;
      case ChallengeType.energy:
        return AppColors.energia;
      case ChallengeType.recycle:
        return AppColors.residuos;
      case ChallengeType.mobility:
        return AppColors.mobilidade;
      case ChallengeType.biodiversity:
        return AppColors.biodiversidade;
    }
  }

  IconData get icon {
    switch (this) {
      case ChallengeType.water:
        return Icons.water_drop_outlined;
      case ChallengeType.energy:
        return Icons.bolt;
      case ChallengeType.recycle:
        return Icons.recycling;
      case ChallengeType.mobility:
        return Icons.directions_bike;
      case ChallengeType.biodiversity:
        return Icons.park_outlined;
    }
  }

  factory ChallengeType.fromMap(String type) {
    switch (type) {
      case "water":
        return ChallengeType.water;
      case "energy":
        return ChallengeType.energy;
      case "recycle":
        return ChallengeType.recycle;
      case "mobility":
        return ChallengeType.mobility;
      case "biodiversity":
        return ChallengeType.biodiversity;
      default:
        throw ArgumentError.value(
          type,
          'type',
          'Invalid challenge type',
        );
    }
  }
}
