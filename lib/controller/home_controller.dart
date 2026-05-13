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
  int get level => _userRepository.getLevel();
  int get numPoints => _userRepository.getNumPoints();
  int get streak => _userRepository.getStreak();


  HomeController(this._context) {
    _initialize();
  }

  Future<void> _initialize() async {
    _userRepository = _context.read<UserRepository>();
    _challengesRepository = _context.read<ChallengesRepository>();

    _getFirstName();
 

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

  Future<void> completeChallenge(Challenge challenge) async {
    final userId = _userRepository.getCurrentUserId()!;

    await _userRepository.completeChallenge(challenge);

    await _challengesRepository.finishChallenge(
      userId,
      challenge.id,
    );

    activeChallenges.removeWhere(
      (c) => c.id == challenge.id,
    );

    notifyListeners();
  }
}