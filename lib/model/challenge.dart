class Challenge {
  String id;
  String title;
  String description;
  int points;
  Difficulty difficulty;
  Duration duration;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.difficulty,
    required this.duration
  });

  factory Challenge.fromMap(String id, Map<String, dynamic> map) {
    return Challenge(
      id: id,
      title: map["title"],
      description: map["description"],
      points: map["points"],
      difficulty: difficultyFromMap(map["difficulty"]),
      duration: durationFromMap(map["duration"])
    );
  }
}

enum Difficulty {
  easy,
  medium,
  hard
}

Difficulty difficultyFromMap(String difficulty) {
  switch (difficulty) {
    case "easy":
      return Difficulty.easy;
    case "medium":
      return Difficulty.medium;
    case "hard":
      return Difficulty.hard;
    default:
      return Difficulty.easy;
  }
}

enum Duration {
  daily,
  weekly,
  monthly
}

Duration durationFromMap(String duration) {
  switch (duration) {
    case "daily":
      return Duration.daily;
    case "weekly":
      return Duration.weekly;
    case "monthly":
      return Duration.monthly;
    default:
      return Duration.daily;
  }
}