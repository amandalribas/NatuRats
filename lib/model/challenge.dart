import 'package:naturats/model/challenge_duration.dart';
import 'package:naturats/model/challenge_type.dart';

class Challenge {
  String id;
  String title;
  String description;
  String details;
  List<String> info;
  ChallengeType type;
  ChallengeDuration duration;
  Map<String,dynamic>? statistics;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.details,
    required this.info,
    required this.type,
    required this.duration,
    this.statistics
  });

  factory Challenge.fromMap(String id, Map<String, dynamic> map) {
    return Challenge(
      id: id,
      title: map["title"] ?? "NULL",
      description: map["description"] ?? "NULL",
      details: map["details"] ?? "NULL",
      info: List<String>.from(map["info"] ?? []),
      type: ChallengeType.fromMap(map["type"] ?? "NULL"),
      duration: ChallengeDuration.fromMap(map["duration"] ?? "")
    );
  }
}