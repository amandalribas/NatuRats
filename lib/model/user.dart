import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String email;
  String name;
  DateTime createdAt;
  DateTime updatedAt;
  int numPoints;
  int level;
  int numMedals;
  int numMissions;
  int streak;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.numPoints,
    required this.level,
    required this.numMedals,
    required this.numMissions,
    required this.streak,

  });

  Map<String, dynamic> toMap() {
    return {
      "email": email,
      "name": name,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "num_points": numPoints,
      "level": level,
      "num_medals": numMedals,
      "num_missions": numMissions,
      "streak": streak,
    };
  }

  factory User.fromMap(String uid, Map<String, dynamic> map) {
    return User(
      id: uid,
      email: map["email"],
      name: map["name"] ?? "",
      createdAt: (map["created_at"] as Timestamp).toDate(),
      updatedAt: (map["updated_at"] as Timestamp).toDate(),
      numPoints: map["num_points"] ?? 0,
      level: map["level"] ?? 0,
      numMedals: map["num_medals"] ?? 0,
      numMissions: map["num_missions"] ?? 0,
      streak: map["streak"] ?? 0,
    );
  }
}