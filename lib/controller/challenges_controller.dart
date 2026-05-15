import 'dart:async';
import 'dart:math';
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

  Set<String> _activeChallengeIds = {};
  List<Challenge> _dailyChallenges = [];
  DateTime? _lastGeneratedDate;
  Timer? _dayChangeTimer;

  ChallengesController(this._context) {
    _initialize();
  }

  Future<void> _initialize() async {
    _challengesRepository = _context.read<ChallengesRepository>();
    _userRepository = _context.read<UserRepository>();

    await _getChallenges();
    await _loadActiveChallengeIds();
    _generateDailyIfNeeded();
    _applyFilters();
    loading = false;
    notifyListeners();
    _startDayChangeTimer();
  }

  Future<void> _getChallenges() async {
    _challenges = await _challengesRepository.getChallenges();
  }

  Future<void> _loadActiveChallengeIds() async {
    final userId = _userRepository.getCurrentUserId();
    if (userId != null) {
      final activeChallenges = await _challengesRepository.getUsersActiveChallenges(userId);
      _activeChallengeIds = activeChallenges.map((c) => c.id).toSet();
    }
  }

  void _generateDailyIfNeeded() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_lastGeneratedDate == today) return;

    _lastGeneratedDate = today;
    final dateString = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final seed = dateString.hashCode;
    final random = Random(seed);

    final available = _challenges.toList();

    List<Challenge> daily = available.where((c) => c.duration == ChallengeDuration.daily).toList();
    List<Challenge> weekly = available.where((c) => c.duration == ChallengeDuration.weekly).toList();
    List<Challenge> monthly = available.where((c) => c.duration == ChallengeDuration.monthly).toList();

    daily.shuffle(random);
    weekly.shuffle(random);
    monthly.shuffle(random);

    _dailyChallenges = [
      ...daily.take(5),
      ...weekly.take(5),
      ...monthly.take(5),
    ];
  }

  void _applyFilters() {
    filteredChallenges = _dailyChallenges.where((challenge) {
      if (_activeChallengeIds.contains(challenge.id)) return false;

      bool durationMatch = selectedDurations.isEmpty || selectedDurations.contains(challenge.duration);
      bool typeMatch = selectedTypes.isEmpty || selectedTypes.contains(challenge.type);
      return durationMatch && typeMatch;
    }).toList();

    notifyListeners();
  }

  void toggleDurationFilter(ChallengeDuration duration) {
    if (selectedDurations.contains(duration)) {
      selectedDurations.remove(duration);
    } else {
      selectedDurations.add(duration);
    }
    _applyFilters();
  }

  void toggleTypeFilter(ChallengeType type) {
    if (selectedTypes.contains(type)) {
      selectedTypes.remove(type);
    } else {
      selectedTypes.add(type);
    }
    _applyFilters();
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
        _activeChallengeIds.add(challengeId);
        _applyFilters();
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

  void _startDayChangeTimer() {
    _dayChangeTimer?.cancel();
    _dayChangeTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      if (_lastGeneratedDate != null && _lastGeneratedDate != today) {
        _generateDailyIfNeeded();
        _applyFilters();
      }
    });
  }

  @override
  void dispose() {
    _dayChangeTimer?.cancel();
    super.dispose();
  }
}