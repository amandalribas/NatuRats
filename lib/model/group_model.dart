class GroupModel {
  String id;
  String name;
  String description;
  int totalPeople = 0;
  int totalPoints = 0;
  String image;

  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.totalPeople,
    required this.totalPoints,
    required this.image
  });
}