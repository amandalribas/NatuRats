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
  String? name;

  HomeController(this._context) {
    _userRepository = _context.read<UserRepository>();
    _challengesRepository = _context.read<ChallengesRepository>();
    name = _userRepository.getFirstName();
    _initialize();
  }

  Future<void> _initialize() async {
    loading = true;
    notifyListeners();
    String? userId = _userRepository.getCurrentUserId();
    activeChallenges = await _challengesRepository
        .getUsersActiveChallenges(userId!);
    loading = false;
    notifyListeners();
  }
}