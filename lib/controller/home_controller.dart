import 'package:flutter/cupertino.dart';
import 'package:naturats/model/challenge.dart';
import 'package:naturats/repository/challenges_repository.dart';
import 'package:naturats/repository/user_repository.dart';
import 'package:provider/provider.dart';

class HomeController extends ChangeNotifier {
  final BuildContext _context;
  late final UserRepository _userRepository;
  late final ChallengesRepository _challengesRepository;

  bool loading = true;
  List<Challenge> activeChallenges = [];
  String? firstName;
  late int level;
  late int numPoints;
  late int streak;

  HomeController(this._context) {
    _initialize();
  }

  Future<void> _initialize() async {
    _userRepository = _context.read<UserRepository>();
    _challengesRepository = _context.read<ChallengesRepository>();

    _getFirstName();
    level = _userRepository.getLevel();
    numPoints = _userRepository.getNumPoints();
    streak = _userRepository.getStreak();

    await _getActiveChallenges();
    loading = false;
    notifyListeners();
  }

  void _getFirstName() {
    firstName = _userRepository.getFirstName();
  }

  

  Future<void> _getActiveChallenges() async {
    String? userId = _userRepository.getCurrentUserId();
    activeChallenges = await _challengesRepository
        .getUsersActiveChallenges(userId!);
  }
}