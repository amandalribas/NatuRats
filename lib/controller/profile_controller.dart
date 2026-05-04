import 'package:flutter/material.dart';
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

  // TODO
  int getUserLevel() {
    return 12;
  }

  // TODO
  int getUserPoints() {
    return 2450;
  }

  // TODO
  int getTotalMedals() {
    return 12;
  }

  // TODO
  int getSequence() {
    return 15;
  }

  // TODO
  int getTotalChallenges() {
    return 32;
  }

  // TODO
  List<Medal> getMedals() {
    return [
      Medal(icon: Icons.recycling, title: 'Rei da reciclagem', description: 'Recicle 100 itens'),
      Medal(icon: Icons.eco, title: 'Habitante da floresta', description: 'Plante uma árvore'),
    ];
  }
}