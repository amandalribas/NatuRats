import 'package:flutter/material.dart';
import 'package:naturats/model/challenge.dart';
import 'package:naturats/model/medal.dart';
import 'package:naturats/repository/user_repository.dart';
import 'package:provider/provider.dart';

class ProfileController extends ChangeNotifier {
  final BuildContext _context;
  late final UserRepository _userRepository;
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

  // TODO
  List<Medal> getMedals() {
    return [
      Medal(icon: Icons.recycling, title: 'Rei da reciclagem', description: 'Recicle 100 itens'),
      Medal(icon: Icons.eco, title: 'Habitante da floresta', description: 'Plante uma árvore'),
    ];
  }

}