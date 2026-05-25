import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:naturats/model/group_model.dart';
import 'package:naturats/repository/group_repository.dart';

class GroupController extends ChangeNotifier {
  late final GroupRepository _groupRepository = GroupRepository();

  List<GroupModel> _allGroups = [];
  Set<String> _myGroupIds = {};

  String _searchText = "";
  bool isLoading = false;

  // TAB INICIAL
  String selectedTab = 'my_groups';

  List<GroupModel> get groups {
    List<GroupModel> filtered;

    if (selectedTab == 'my_groups') {
      filtered =
          _allGroups.where((g) => _myGroupIds.contains(g.id)).toList();
    } else {
      filtered =
          _allGroups.where((g) => !_myGroupIds.contains(g.id)).toList();
    }

    if (_searchText.isNotEmpty) {
      filtered = filtered
          .where(
            (g) => g.name.toLowerCase().contains(_searchText),
          )
          .toList();
    }

    return filtered;
  }

  Future<List<GroupModel>> loadGroups() async {
    isLoading = true;
    notifyListeners();

    final userEmail = FirebaseAuth.instance.currentUser!.email!;

    _allGroups = await _groupRepository.fetchVisibleGroups(userEmail);

    _myGroupIds = await _groupRepository.getUserGroupIds(userEmail);

    isLoading = false;
    notifyListeners();

    return groups;
  }

  void setTab(String tab) {
    if (selectedTab == tab) return;

    selectedTab = tab;
    notifyListeners();
  }

  void updateSearch(String value) {
    _searchText = value.toLowerCase();
    notifyListeners();
  }

  Future<void> createGroup({
    required String name,
    required String description,
    required String imageBase64,
    required bool isPublic,
  }) async {
    await _groupRepository.createGroup(
      name: name,
      description: description,
      imageBase64: imageBase64,
      isPublic: isPublic,
    );

    await loadGroups();
  }
}