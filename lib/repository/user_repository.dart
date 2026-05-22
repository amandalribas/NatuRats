import 'package:flutter/cupertino.dart';
import 'package:naturats/model/challenge.dart';
import 'package:naturats/model/completed_challenges.dart';
import 'package:naturats/model/medal.dart';
import 'package:naturats/service/auth_service.dart';
import 'package:naturats/service/challenges_service.dart';
import 'package:naturats/service/medal_service.dart';
import 'package:naturats/service/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user.dart';

class UserRepository extends ChangeNotifier {
  final AuthenticationService _authService = AuthenticationService();
  final UserService _userService = UserService();
  final ChallengesService _challengesService = ChallengesService();

  User? _currentUser;
  bool isSignedIn = false;
  bool isLoading = true;
  String? profilePictureUrl;
  List<CompletedChallenges> completedChallenges = [];

  UserRepository() {
    _initialize();
  }

  Future<void> _initialize() async {
    if (_authService.isSignedIn()) {
      await _getCurrentUserInfo();
      isSignedIn = true;
    }
    await getCompletedChallenges();
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
        fbAuthUser.displayName,
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
        streak: 0,
        statistics: {"CO2": 0, "water": 0, "recycled": 0, "km": 0},
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
    debugPrint("chamada");
    if (_currentUser == null) return;

    _currentUser!.numPoints += challenge.duration.points;
    final limit = 50 * _currentUser!.level;

    if (_currentUser!.numPoints >= limit) {
      _currentUser!.numPoints -= limit;
      _currentUser!.level++;
    }

    _currentUser!.numMissions += 1;

    // TODO: streak

    challenge.statistics.forEach((key, value) {
      if (value != null) {
        final int addedValue = int.tryParse(value.toString()) ?? 0;
        if (_currentUser!.statistics != null) {
          // Normaliza: co2, Co2, CO2 → sempre 'CO2'
          final String normalizedKey = key.toLowerCase() == 'co2' ? 'CO2' : key;
          _currentUser!.statistics![normalizedKey] =
              (_currentUser!.statistics![normalizedKey] ?? 0) + addedValue;
        }
      }
    });

    await _syncMedalCount();
    await _userService.update(_currentUser!);

    notifyListeners();
  }

  Future<void> _syncMedalCount() async {
    if (_currentUser == null) return;

    try {
      final MedalService medalService = MedalService();
      final List<Medal> medals = await medalService.getMedalsOnce();

      final stats = getStatistics();
      final int streak = getStreak();
      final int completedMissionsCount = completedChallenges.length;

      final Map<String, int> statsFormatados = {
        'CO2': stats['CO2'] ?? stats['co2'] ?? 0,
        'co2': stats['co2'] ?? stats['CO2'] ?? 0,
        'water': stats['water'] ?? 0,
        'recycled': stats['recycled'] ?? 0,
        'km': stats['km'] ?? 0,
      };

      debugPrint("Stats para medalhas: $statsFormatados");

      for (var medal in medals) {
        medal.checkUnlockStatus(
          statsFormatados,
          streak,
          completedMissionsCount,
        );
      }

      final int unlockedCount = medals.where((m) => m.isUnlocked).length;
      debugPrint("Medalhas desbloqueadas: $unlockedCount");

      _currentUser!.numMedals = unlockedCount;
    } catch (e) {
      debugPrint("Erro ao sincronizar medalhas: $e");
    }
  }

  int getNumPoints() {
    return _currentUser?.numPoints ?? 0;
  }

  int getLevel() {
    return _currentUser?.level ?? 0;
  }

  int getNumMedals() {
    return _currentUser?.numMedals ?? 0;
  }

  int getNumMissions() {
    return _currentUser?.numMissions ?? 0;
  }

  int getStreak() {
    return _currentUser?.streak ?? 0;
  }

  Map<String, int> getStatistics() {
    return _currentUser?.statistics ??
        {"CO2": 0, "water": 0, "recycled": 0, "km": 0};
  }

  Future<void> getCompletedChallenges() async {
    final userId = _currentUser?.id;
    final List<CompletedChallenges> challenges = userId != null
        ? await _challengesService.getUserCompletedChallenges(userId)
        : [];

    completedChallenges = challenges
        .map(
          (c) => CompletedChallenges(
            title: c.title,
            points: c.points,
            completedAt: c.completedAt,
          ),
        )
        .toList();

    notifyListeners();
  }
}
