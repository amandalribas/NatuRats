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
  Map<String, int>? statistics;
  DateTime? lastCheckInDate;
  Map<String, String>? lastCheckInReminderSentSlots;
  DateTime? lastCheckInReminderSentAt;

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
    required this.statistics,
    this.lastCheckInDate,
    this.lastCheckInReminderSentSlots,
    this.lastCheckInReminderSentAt,
  });

  Map<String, dynamic> toMap() {
    final data = {
      "email": email,
      "name": name,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "num_points": numPoints,
      "level": level,
      "num_medals": numMedals,
      "num_missions": numMissions,
      "streak": streak,
      "statistics": statistics,
      "last_check_in_date": lastCheckInDate,
    };

    if (lastCheckInReminderSentSlots != null) {
      data["last_checkin_reminder_sent_slots"] = lastCheckInReminderSentSlots;
    }

    if (lastCheckInReminderSentAt != null) {
      data["last_checkin_reminder_sent_at"] = lastCheckInReminderSentAt;
    }

    return data;
  }

  factory User.fromMap(String uid, Map<String, dynamic> map) {
    final reminderSlots = map["last_checkin_reminder_sent_slots"];

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
      statistics: Map<String, int>.from(
        map["statistics"] ?? {"CO2": 0, "water": 0, "recycled": 0, "km": 0},
      ),
      lastCheckInDate: (map["last_check_in_date"] as Timestamp?)?.toDate(),
      lastCheckInReminderSentSlots: reminderSlots is Map
          ? reminderSlots.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            )
          : null,
      lastCheckInReminderSentAt:
          (map["last_checkin_reminder_sent_at"] as Timestamp?)?.toDate(),
    );
  }
}
