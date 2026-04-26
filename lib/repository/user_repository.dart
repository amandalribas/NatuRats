import 'package:flutter/cupertino.dart';
import 'package:naturats/service/auth_service.dart';
import 'package:naturats/service/user_service.dart';
import '../model/user.dart';

class UserRepository extends ChangeNotifier {
  final AuthenticationService _authService = AuthenticationService();
  final UserService _userService = UserService();

  User? currentUser;
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
    currentUser = null;
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
      currentUser = user;
    }
  }

  Future<void> _createUser(String uid, String? email, String? name) async {
    try {
      User newUser = User(
        id: uid,
        email: email ?? "",
        name: name ?? "",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now()
      );

      await _userService.create(newUser);
      currentUser = newUser;
    } catch (e) {
      debugPrint("Error on create user: $e");
    }
  }

  String? getFirstName() {
    String? name = currentUser?.name;

    final index = name?.indexOf(' ');
    return index == -1 ? name : name?.substring(0, index);
  }

  String? getFullName() {
    return currentUser?.name;
  }

  String? getProfilePictureUrl() {
    return profilePictureUrl;
  }
}