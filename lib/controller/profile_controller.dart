import 'package:flutter/material.dart';
import 'package:naturats/model/completed_challenges.dart';
import 'package:naturats/model/medal.dart';
import 'package:naturats/repository/user_repository.dart';
import 'package:naturats/service/medal_service.dart';
import 'package:provider/provider.dart';

class ProfileController extends ChangeNotifier {
  final BuildContext _context;
  late final UserRepository _userRepository;
  final MedalService _medalService = MedalService();
  late String? fullName;

  ProfileController(this._context) {
    _userRepository = _context.read<UserRepository>();
    fullName = _userRepository.getFullName();
  }

  ImageProvider<Object>? getProfilePic() {
    final url = _userRepository.getProfilePictureUrl();
    if (url != null) {
      return NetworkImage(url);
    }
    return null;
  }

  int getUserLevel() {
    return _userRepository.getLevel();
  }

  int getUserPoints() {
    return _userRepository.getNumPoints();
  }

  int getSequence() {
    return _userRepository.getStreak();
  }

  int getTotalChallenges() {
    return _userRepository.getNumMissions();
  }

  Map<String, int> getStatistics() {
    return _userRepository.getStatistics();
  }

  int getTotalMedals() => _userRepository.getNumMedals();

  Stream<List<Medal>> getMedalsStream() {
    return _medalService.getMedalsStream().map((medalList) {
      final int streak = _userRepository.getStreak();
      final int completedMissionsCount =
          _userRepository.completedChallenges.length;
      final stats = _userRepository.getStatistics();

      // Preserva 'CO2' maiúsculo (como vem do Firestore/challenge.statistics)
      final Map<String, int> statsFormatados = {
        'CO2': stats['CO2'] ?? stats['co2'] ?? 0,
        'co2': stats['co2'] ?? stats['CO2'] ?? 0,
        'water': stats['water'] ?? 0,
        'recycled': stats['recycled'] ?? 0,
        'km': stats['km'] ?? 0,
      };

      for (var medal in medalList) {
        medal.checkUnlockStatus(
          statsFormatados,
          streak,
          completedMissionsCount,
        );
      }
      return medalList;
    });
  }

  Stream<int> getUnlockedMedalsCountStream() {
    return getMedalsStream().map((medalList) {
      return medalList.where((medal) => medal.isUnlocked).length;
    });
  }

  List<CompletedChallenges> getCompletedChallenges() {
    return _userRepository.completedChallenges;
  }

  Future<List<int>> getWeeklyPoints() async {
    return _userRepository.getWeeklyPoints();
  }
}
