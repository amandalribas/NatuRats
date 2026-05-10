import 'package:flutter/material.dart';
import 'package:naturats/model/challenge.dart';
import 'package:naturats/repository/challenges_repository.dart';
import 'package:naturats/repository/user_repository.dart';
import 'package:provider/provider.dart';
import '../view/challenge_details_page.dart';
import '../model/challenge_duration.dart';
import '../model/challenge_type.dart';

class ChallengesController extends ChangeNotifier {
  final BuildContext _context;
  late final ChallengesRepository _challengesRepository;
  late final UserRepository _userRepository;

  List<Challenge> _challenges = [];
  Set<ChallengeDuration> selectedDurations = {};
  Set<ChallengeType> selectedTypes = {};
  bool loading = true;

  ChallengesController(this._context) {
    _challengesRepository = _context.read<ChallengesRepository>();
    _userRepository = _context.read<UserRepository>();
    _getChallenges();
  }

  Future<void> _getChallenges() async {
    loading = true;
    notifyListeners();
    _challenges = await _challengesRepository.getAllChallenges();
    loading = false;
    notifyListeners();
  }

  void onTapChallengeBox(Challenge challenge) {
    Navigator.push(
      _context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: this,
          child: DetailChallengeBox(
            challenge: challenge,
          ),
        ),
      ),
    );
  }

  List<Challenge> getFilteredChallenges () {
    return _challenges.where((challenge) {
      bool durationMatch = selectedDurations.isEmpty ||
          selectedDurations.contains(challenge.duration);

      bool typeMatch = selectedTypes.isEmpty ||
              selectedTypes.contains(challenge.type);

      return durationMatch && typeMatch;
    }).toList();
  }

  void toggleDurationFilter(ChallengeDuration duration) {
    if (selectedDurations.contains(duration)) {
      selectedDurations.remove(duration);
    } else {
      selectedDurations.add(duration);
    }

    notifyListeners();
  }

  void toggleTypeFilter(ChallengeType type) {
    if (selectedTypes.contains(type)) {
      selectedTypes.remove(type);
    } else {
      selectedTypes.add(type);
    }

    notifyListeners();
  }

  Future<void> addChallengeToUserLibrary(String challengeId) async {
    String? userId = _userRepository.getCurrentUserId();
    await _challengesRepository.startChallenge(userId!, challengeId);
  }
}