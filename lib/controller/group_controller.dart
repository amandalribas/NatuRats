import 'package:flutter/material.dart';
import 'package:naturats/model/group_model.dart';
import 'package:naturats/repository/group_repository.dart';

class GroupController extends ChangeNotifier {
  late final GroupRepository _groupRepository = GroupRepository();
  List<GroupModel> groups = [];
  bool isLoading = false;


  Future<List<GroupModel>> loadGroups() async {
    isLoading = true;
    notifyListeners();

    final groups = await _groupRepository.fetchGroups();
    this.groups = groups;

    isLoading = false;
    notifyListeners();

    return groups;
  }

  void createGroup({
    required String name,
    required String description,
    required String imageBase64,
    required bool isPublic
  }) {
    _groupRepository.createGroup(
      name: name, 
      description: description, 
      imageBase64: imageBase64,
      isPublic: isPublic);
  }

}