import 'package:flutter/cupertino.dart';
import 'package:naturats/model/challenge.dart';
import 'package:naturats/service/auth_service.dart';
import 'package:naturats/service/user_service.dart';
import '../model/user.dart';

class UserRepository extends ChangeNotifier {
  final AuthenticationService _authService = AuthenticationService();
  final UserService _userService = UserService();

  User? _currentUser;
  bool isSignedIn = false;
  bool isLoading = true;
  String? profilePictureUrl;

  UserRepository() {
    _initialize();
  }

  Future<void> _initialize() async {
    if (_authService.isSignedIn()) {
      await _getCurrentUserInfo();
      isSignedIn = true;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> login() async {
    if (await _authService.signInWithGoogle()) {
      await _getCurrentUserInfo();
      isSignedIn = true;
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null;
    isSignedIn = false;
    profilePictureUrl = null;
    notifyListeners();
  }

  Future<void> _getCurrentUserInfo() async {
    final fbAuthUser = _authService.getFirebaseAuthUser();
    User? user = await _userService.get(fbAuthUser!.uid);
    profilePictureUrl = fbAuthUser.photoURL;

    if (user == null) {
      await _createUser(
        fbAuthUser.uid,
        fbAuthUser.email,
        fbAuthUser.displayName
      );
    } else {
      _currentUser = user;
    }
  }

  Future<void> _createUser(String uid, String? email, String? name) async {
    try {
      User newUser = User(
        id: uid,
        email: email ?? "",
        name: name ?? "",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        numPoints: 0,
        level: 1,
        numMedals: 0,
        numMissions: 0,
        streak: 0
      );

      await _userService.create(newUser);
      _currentUser = newUser;
    } catch (e) {
      debugPrint("Error on create user: $e");
    }
  }

  String? getFirstName() {
    String? name = _currentUser?.name;

    final index = name?.indexOf(' ');
    return index == -1 ? name : name?.substring(0, index);
  }

  String? getFullName() {
    return _currentUser?.name;
  }

  String? getCurrentUserId() {
    return _currentUser?.id;
  }

  String? getProfilePictureUrl() {
    return profilePictureUrl;
  }

  Future<void> completeChallenge(Challenge challenge) async {
    if (_currentUser == null) return;

    print("ANTES: ${_currentUser!.numPoints}");


    _currentUser!.numPoints += challenge.duration.points;



print("DEPOIS: ${_currentUser!.numPoints}");

    final limit = 50 * _currentUser!.level;

    if (_currentUser!.numPoints >= limit) {
      _currentUser!.numPoints -= limit;
      _currentUser!.level++;
    }

    _currentUser!.numMissions += 1;

    // TODO: medalhas
    // TODO: streak

    _currentUser!.updatedAt = DateTime.now();

    await _userService.update(_currentUser!);

    notifyListeners();
  }

  int getNumPoints(){
    return _currentUser?.numPoints ?? 0;
  }

  int getLevel(){
    return _currentUser?.level ?? 0;
  }

  int getNumMedals(){
    return _currentUser?.numMedals ?? 0;
  }

  int getNumMissions(){
    return _currentUser?.numMissions ?? 0;
  }

  int getStreak(){
    return _currentUser?.streak ?? 0;
  }

}