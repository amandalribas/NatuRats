import 'package:flutter/material.dart';

class Medal {
  //IconData icon;
  final String id;
  String title;
  String description;
  String type; // mobility, recycle, water, energy, consistency
  bool isUnlocked; //controlando se o usuário já possui ou nao

  Medal({
    //required this.icon,
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.isUnlocked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      //"icon": icon,
      "title": title,
      "description": description,
      "type": type,
    };
  }

  factory Medal.fromMap(String id, Map<String, dynamic> map) {
    return Medal(
      id: id,
      //icon: map["icon"],
      title: map["title"] ?? '',
      type: map["type"] ?? "water",
      description: map["description"] ?? '',
      isUnlocked: map["isUnlocked"] == true,
    );
  }

  IconData getIcon() {
    switch (type) {
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

  void checkUnlockStatus(Map<String, int> userStats, int currentStreak, int completedMissionsCount) {
    final int requirement = _extractRequirement(title);

    // Normaliza o tipo para evitar que espaços ou maiúsculas quebrem o switch
    switch (type.trim().toLowerCase()) {
      case 'water':
        final waterSaved = userStats['water'] ?? 0; 
        isUnlocked = waterSaved >= requirement;
        break;

      case 'recycle':
        final itemsRecycled = userStats['recycled'] ?? userStats['recycle'] ?? 0; // Aceita as duas variantes
        isUnlocked = itemsRecycled >= requirement;
        break;

      case 'energy': 
      case 'co2': // Agora aceita 'co2' vindo do seu repositório/view
        final co2Avoided = userStats['co2'] ?? userStats['energy'] ?? 0;
        
        // Se no repositório o CO2 estiver salvo em gramas (como sugere a sua View: co2 / 1000), 
        // e o título da medalha exigir "kg" (ex: 5 kg), fazemos a conversão automática aqui:
        final currentCo2InKg = co2Avoided >= 1000 ? (co2Avoided / 1000).floor() : co2Avoided;
        
        isUnlocked = (co2Avoided >= requirement) || (currentCo2InKg >= requirement);
        break;

      case 'mobility': 
      case 'km': // Agora aceita 'km' vindo do seu repositório/view
        final kmSustained = userStats['km'] ?? userStats['mobility'] ?? 0;
        isUnlocked = kmSustained >= requirement;
        break;

      case 'consistency': 
        isUnlocked = currentStreak >= requirement;
        break;

      default:
        isUnlocked = completedMissionsCount >= requirement;
        break;
    }
  }

  /// Expressão regular aprimorada para capturar números colados em letras (ex: "100km")
  int _extractRequirement(String text) {
    final RegExp regex = RegExp(r'\d+'); 
    final match = regex.firstMatch(text.replaceAll('.', '')); 
    if (match != null) {
      return int.tryParse(match.group(0) ?? '0') ?? 0;
    }
    return 1; 
  }
}
