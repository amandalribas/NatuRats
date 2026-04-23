import 'package:flutter/cupertino.dart';
import 'package:naturats/repository/user_repository.dart';
import 'package:provider/provider.dart';

class HomeController extends ChangeNotifier {
  final BuildContext _context;
  late final UserRepository _userRepository;
  bool loading = false;
  late String? name;

  HomeController(this._context) {
    _userRepository = _context.read<UserRepository>();
    name = _userRepository.getFirstName();
  }
}