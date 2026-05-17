import 'package:flutter/material.dart';

class Medal {
  //IconData icon;
  final String id;
  String title;
  String description;
  String type; // mobility, recycle, water, energy, consistency
  final bool isUnlocked; //controlando se o usuário já possui ou nao

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
}
