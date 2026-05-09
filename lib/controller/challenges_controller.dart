import 'package:flutter/material.dart';
import 'package:naturats/model/challenge.dart';
import 'package:naturats/repository/challenges_repository.dart';
import 'package:provider/provider.dart';
import '../components/challenge/detail_challenge_box.dart';
import '../model/challenge_duration.dart';
import '../model/challenge_type.dart';

class ChallengesController extends ChangeNotifier {
  final BuildContext _context;
  late final ChallengesRepository _challengesRepository;
  List<Challenge> _challenges = [];
  Set<ChallengeDuration> selectedDurations = {};
  Set<ChallengeType> selectedTypes = {};
  bool loading = true;

  ChallengesController(this._context) {
    _challengesRepository = _context.read<ChallengesRepository>();
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
        builder: (context) =>  DetailChallengeBox(
          title: challenge.title,
          descr: challenge.description,
          duration: challenge.duration,
          type: challenge.type,
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
}