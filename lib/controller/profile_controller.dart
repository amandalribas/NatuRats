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

  // TODO
  int getTotalMedals() {
    return _userRepository.getNumMedals();
  }

  // TODO
  int getSequence() {
    return _userRepository.getStreak();
  }

  // TODO
  int getTotalChallenges() {
    return _userRepository.getNumMissions();
  }

  Map<String, int> getStatistics() {
    return _userRepository.getStatistics();
  }


  Stream<List<Medal>> getMedalsStream() {
    final int streak = _userRepository.getStreak();
    final int completedMissionsCount = _userRepository.completedChallenges.length; 
    
    
    final Map<String, int> statsFormatados = {
      'co2': _userRepository.getStatistics()['co2'] ?? _userRepository.getNumPoints(), // Ajuste conforme seu repositório
      'water': _userRepository.getStatistics()['water'] ?? 0,
      'recycled': _userRepository.getStatistics()['recycled'] ?? _userRepository.getStatistics()['recycle'] ?? 0,
      'km': _userRepository.getStatistics()['km'] ?? 0,
    };

    return _medalService.getMedalsStream().map((medalList) {
      for (var medal in medalList) {
        medal.checkUnlockStatus(statsFormatados, streak, completedMissionsCount);
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


}
