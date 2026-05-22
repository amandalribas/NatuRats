import 'package:flutter/material.dart';

class Medal {
  final String id;
  String title;
  String description;
  String type;
  bool isUnlocked;

  Medal({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.isUnlocked = false,
  });

  Map<String, dynamic> toMap() {
    return {"title": title, "description": description, "type": type};
  }

  factory Medal.fromMap(String id, Map<String, dynamic> map) {
    return Medal(
      id: id,
      title: map["title"] ?? '',
      type: map["type"] ?? "water",
      description: map["description"] ?? '',
      isUnlocked: map["isUnlocked"] == true,
    );
  }

  IconData getIcon() {
    switch (type.trim().toLowerCase()) {
      case 'water':
        return Icons.water_drop;
      case 'recycle':
        return Icons.recycling;
      case 'energy':
        return Icons.bolt;
      case 'mobility':
        return Icons.directions_run;
      case 'consistency':
        return Icons.calendar_month;
      default:
        return Icons.emoji_events;
    }
  }

  /// Requisitos fixos por título (trim para remover espaços extras do Firestore)
  static const Map<String, int> _requirements = {
    // water
    'Primeiras Gotas': 100,
    'Guardião da Água': 500,
    'Mestre da Economia': 1000,
    // recycle
    'Reciclador iniciante': 100,
    'Herói da Reciclagem': 500,
    'Lenda sustentável': 1000,
    // energy (CO2 em gramas no Firestore → comparar com kg)
    'Menos Carbono': 10,
    'Ar mais Limpo': 50,
    'Impacto Verde': 100,
    // mobility
    'Primeiros Passos': 50,
    'Mobilidade Consciente': 100,
    'Eco viajante': 500,
    // consistency (streak)
    'Semana Sustentável': 7,
    'Compromisso Verde': 30,
    // missions
    'Semente Verde': 1,
    'Amigo do Planeta': 15,
    'Mestre das Missões': 100,
  };

  int get requirement {
    final trimmed = title.trim();
    return _requirements[trimmed] ?? 1;
  }

  void checkUnlockStatus(
    Map<String, int> userStats,
    int currentStreak,
    int completedMissionsCount,
  ) {
    final int req = requirement;

    // Títulos que usam streak (dias seguidos)
    const streakTitles = {'Semana Sustentável', 'Compromisso Verde'};

    switch (type.trim().toLowerCase()) {
      case 'water':
        isUnlocked = (userStats['water'] ?? 0) >= req;
        break;
      case 'recycle':
        isUnlocked = (userStats['recycled'] ?? 0) >= req;
        break;
      case 'energy':
        final int co2Grams = userStats['CO2'] ?? userStats['co2'] ?? 0;
        final int co2Kg = (co2Grams / 1000).floor();
        isUnlocked = co2Kg >= req;
        break;
      case 'mobility':
        isUnlocked = (userStats['km'] ?? 0) >= req;
        break;
      case 'consistency':
        if (streakTitles.contains(title.trim())) {
          // Medalhas de dias consecutivos
          isUnlocked = currentStreak >= req;
        } else {
          // Medalhas de missões completas (Semente Verde, Amigo do Planeta, etc.)
          isUnlocked = completedMissionsCount >= req;
        }
        break;
      default:
        isUnlocked = completedMissionsCount >= req;
        break;
    }
  }
}
