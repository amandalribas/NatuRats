import 'package:flutter/material.dart';
import 'package:naturats/model/challenge.dart';
import 'package:naturats/repository/challenges_repository.dart';
import 'package:naturats/repository/user_repository.dart';
import 'package:provider/provider.dart';
import '../components/custom_snackbar.dart';
import '../theme/app_colors.dart';
import '../view/challenge_detail_page.dart';
import '../model/challenge_duration.dart';
import '../model/challenge_type.dart';

class ChallengesController extends ChangeNotifier {
  final BuildContext _context;
  late final ChallengesRepository _challengesRepository;
  late final UserRepository _userRepository;

  List<Challenge> _challenges = [];
  List<Challenge> filteredChallenges = [];
  final Set<ChallengeDuration> selectedDurations = {};
  final Set<ChallengeType> selectedTypes = {};
  bool loading = true;

  ChallengesController(this._context) {
    _initialize();
  }

  Future<void> _initialize() async {
    _challengesRepository = _context.read<ChallengesRepository>();
    _userRepository = _context.read<UserRepository>();

    await _getChallenges();
    _filterChallenges();
    loading = false;
    notifyListeners();
  }

  Future<void> _getChallenges() async {
    _challenges = await _challengesRepository.getChallenges();
  }

  void _filterChallenges () {
    filteredChallenges = _challenges.where((challenge) {
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

    _filterChallenges();
    notifyListeners();
  }

  void toggleTypeFilter(ChallengeType type) {
    if (selectedTypes.contains(type)) {
      selectedTypes.remove(type);
    } else {
      selectedTypes.add(type);
    }

    _filterChallenges();
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

  Future<void> addChallengeToUserLibrary(String challengeId) async {
    try {
      String? userId = _userRepository.getCurrentUserId();
      await _challengesRepository.startChallenge(userId!, challengeId);
      if (_context.mounted) {
        CustomSnackbar.show(
          context: _context,
          message: "Desafio iniciado!",
          color: AppColors.bgVerde,
        );
        Navigator.pop(_context);
      }
    } catch (e) {
      debugPrint("Error on challenges controller, new active challenge: $e");
      if (_context.mounted) {
        CustomSnackbar.show(
          context: _context,
          message: "Erro ao iniciar desafio",
          color: AppColors.vermelho,
        );
      }
    }
  }
}