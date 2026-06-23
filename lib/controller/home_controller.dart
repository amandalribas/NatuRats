import 'package:flutter/material.dart';
import 'package:naturats/model/challenge.dart';
import 'package:naturats/repository/challenges_repository.dart';
import 'package:naturats/repository/user_repository.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends ChangeNotifier {
  final BuildContext _context;
  late final UserRepository _userRepository;
  late final ChallengesRepository _challengesRepository;

  bool loading = true;
  List<Challenge> activeChallenges = [];
  String? firstName;
  bool _disposed = false;   // ← ADICIONADO

  final Map<String, int> _progressCache = {};
  static const String _progressKeyPrefix = 'challenge_progress_';

  int get level => _userRepository.getLevel();
  int get numPoints => _userRepository.getNumPoints();
  int get streak => _userRepository.getStreak();

  HomeController(this._context) {
    _initialize();
  }

  Future<void> _initialize() async {
    _userRepository = _context.read<UserRepository>();
    _challengesRepository = _context.read<ChallengesRepository>();

    _userRepository.addListener(_onUserRepositoryChanged);

    _getFirstName();
    await _getActiveChallenges();
    await _loadAllProgresses();

    loading = false;
    if (!_disposed) {          // ← PROTEÇÃO
      notifyListeners();
    }
  }

  void _onUserRepositoryChanged() {
    if (!_disposed) {          // ← PROTEÇÃO
      notifyListeners();
    }
  }

  void _getFirstName() {
    firstName = _userRepository.getFirstName();
  }

  Future<void> _getActiveChallenges() async {
    String? userId = _userRepository.getCurrentUserId();
    activeChallenges = await _challengesRepository.getActiveChallenges(userId!);
  }

  Future<int> loadProgress(String challengeId) async {
    if (_progressCache.containsKey(challengeId)) {
      return _progressCache[challengeId]!;
    }
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_progressKeyPrefix + challengeId) ?? 0;
    _progressCache[challengeId] = saved;
    return saved;
  }

  Future<void> saveProgress(String challengeId, int progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_progressKeyPrefix + challengeId, progress);
    _progressCache[challengeId] = progress;
    if (!_disposed) {          // ← PROTEÇÃO
      notifyListeners();
    }
  }

  Future<void> incrementProgress(Challenge challenge) async {
    int current = await loadProgress(challenge.id);
    if (current >= challenge.goal) return;
    int newProgress = current + 1;
    await saveProgress(challenge.id, newProgress);
    await _userRepository.updateStreakOnCheckIn();
  }

  int getProgress(String challengeId) {
    return _progressCache[challengeId] ?? 0;
  }

  Future<void> _loadAllProgresses() async {
    for (var challenge in activeChallenges) {
      await loadProgress(challenge.id);
    }
  }

  Future<void> completeChallenge(Challenge challenge) async {
    final userId = _userRepository.getCurrentUserId()!;

    await _userRepository.completeChallenge(challenge);
    await _challengesRepository.finishChallenge(userId, challenge.id);
    await _userRepository.getCompletedChallenges();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressKeyPrefix + challenge.id);
    _progressCache.remove(challenge.id);

    activeChallenges.removeWhere((c) => c.id == challenge.id);
    
    if (!_disposed) {          // ← AQUI estava o erro
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;          // ← MARCA COMO DISPOSTO
    _userRepository.removeListener(_onUserRepositoryChanged);
    super.dispose();
  }
}