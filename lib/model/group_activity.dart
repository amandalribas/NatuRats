// lib/models/group_activity.dart
class GroupActivity {
  final String id;
  final String senderName;
  final String senderId;
  final String title;
  final String description;
  final String missionType;
  final String? photoBase64;
  final DateTime? createdAt;

  GroupActivity({
    required this.id,
    required this.senderName,
    required this.senderId,
    required this.title,
    required this.description,
    required this.missionType,
    this.photoBase64,
    this.createdAt,
  });
}