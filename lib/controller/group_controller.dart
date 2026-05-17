import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:naturats/model/group_model.dart';
import 'package:naturats/repository/group_repository.dart';

class GroupController extends ChangeNotifier {
  late final GroupRepository _groupRepository = GroupRepository();
  List<GroupModel> _groups = [];
  String _searchText = "";
  bool isLoading = false;

  Future<List<GroupModel>> loadGroups() async {
    isLoading = true;
    notifyListeners();

    final groups = await _groupRepository.fetchVisibleGroups(FirebaseAuth.instance.currentUser!.email!);
    _groups = groups;

    isLoading = false;
    notifyListeners();

    return groups;
  }

  List<GroupModel> get groups {
    if (_searchText.isEmpty) {
      return _groups;
    }

    return _groups.where((group) {
      return group.name
          .toLowerCase()
          .contains(_searchText);
    }).toList();
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

  void updateSearch(String value) {
    _searchText = value.toLowerCase();
    notifyListeners();
  }
}