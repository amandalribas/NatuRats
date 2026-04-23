import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String email;
  String name;
  DateTime createdAt;
  DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
    required this.updatedAt
  });

  Map<String, dynamic> toMap() {
    return {
      "email": email,
      "name": name,
      "created_at": createdAt,
      "updated_at": updatedAt
    };
  }

  factory User.fromMap(String uid, Map<String, dynamic> map) {
    return User(
      id: uid,
      email: map["email"],
      name: map["name"] ?? "",
      createdAt: (map["created_at"] as Timestamp).toDate(),
      updatedAt: (map["updated_at"] as Timestamp).toDate(),
    );
  }
}