import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:naturats/model/group_model.dart';
import 'package:naturats/repository/group_repository.dart';

class GroupJoinController extends ChangeNotifier {
  GroupJoinController({GroupRepository? groupRepository, FirebaseAuth? auth})
      : _groupRepository = groupRepository ?? GroupRepository(),
        _auth = auth ?? FirebaseAuth.instance;

  final GroupRepository _groupRepository;
  final FirebaseAuth _auth;

  bool _isJoining = false;

  bool get isJoining => _isJoining;

  Future<String?> join(GroupModel group) async {
    final userEmail = _auth.currentUser?.email;

    if (userEmail == null) {
      return null;
    }

    _isJoining = true;
    notifyListeners();

    try {
      await _groupRepository.addMemberToGroup(group.id, userEmail);
      return userEmail;
    } finally {
      _isJoining = false;
      notifyListeners();
    }
  }
}