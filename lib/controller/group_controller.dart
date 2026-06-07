import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:naturats/model/group_model.dart';
import 'package:naturats/repository/group_repository.dart';

class GroupController extends ChangeNotifier {
  late final GroupRepository _groupRepository = GroupRepository();

  List<GroupModel> _allGroups = [];
  Set<String> _myGroupIds = {};

  List<GroupModel> _myGroups = [];
  List<GroupModel> _generalGroups = [];

  String _searchText = "";
  bool isLoading = false;

  // TAB INICIAL
  String selectedTab = 'my_groups';


  List<GroupModel> get groups {
    List<GroupModel> currentList = (selectedTab == 'my_groups') ? _myGroups : _generalGroups;

    if (_searchText.isNotEmpty) {
      return currentList
          .where((g) => g.name.toLowerCase().contains(_searchText))
          .toList();
    }

    return currentList;
  }

  Future<void> loadGroups({bool forceRefresh = false}) async {
    // Se a lista já tem dados e não foi pedido um refresh forçado, não faz nada (evita re-queries)
    if (selectedTab == 'my_groups' && _myGroups.isNotEmpty && !forceRefresh) return;
    if (selectedTab == 'general' && _generalGroups.isNotEmpty && !forceRefresh) return;

    isLoading = true;
    notifyListeners();

    try {
      final userEmail = FirebaseAuth.instance.currentUser!.email!;

      if (selectedTab == 'my_groups') {
        _myGroups = await _groupRepository.fetchMyGroupsOnly(userEmail);
      } else {
        _generalGroups = await _groupRepository.fetchGeneralGroupsOnly(userEmail);
      }
    } catch (e) {
      debugPrint("Erro ao carregar aba $selectedTab: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setTab(String tab) {
    if (selectedTab == tab) return;

    selectedTab = tab;
    notifyListeners();

    // Carrega os dados da nova aba caso ainda não tenham sido buscados
    loadGroups();
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

    _myGroups.clear();
    _generalGroups.clear();
    await loadGroups();
  }
}