import 'package:cloud_firestore/cloud_firestore.dart';

class Invitation {
  String id;
  String sender;
  String recipient;
  String group;
  DateTime deadline;

  Invitation({
    required this.id,
    required this.sender,
    required this.recipient,
    required this.group,
    required this.deadline,
  });

  Map<String, dynamic> toMap() {
    return {
      "sender": sender,
      "recipient": recipient,
      "group": group,
      "deadline": Timestamp.fromDate(deadline),
    };
  }

  factory Invitation.fromMap(String id, Map<String, dynamic> map) {
    return Invitation(
      id: id,
      sender: map["sender"],
      recipient: map["recipient"],
      group: map["group"],
      deadline: (map["deadline"] as Timestamp).toDate(),
    );
  }
}
