import 'package:flutter/material.dart';

class Medal {
  IconData icon;
  String title;
  String description;

  Medal({
    required this.icon,
    required this.title,
    required this.description
  });

  Map<String, dynamic> toMap() {
    return {
      "icon": icon,
      "title": title,
      "description": description
    };
  }

  factory Medal.fromMap(Map<String, dynamic> map) {
    return Medal(
      icon: map["icon"],
      title: map["title"],
      description: map["description"]
    );
  }
}