import 'package:flutter/cupertino.dart';
import 'package:naturats/repository/user_repository.dart';
import 'package:provider/provider.dart';

class LoginController extends ChangeNotifier {
  final BuildContext _context;
  late final UserRepository _userRepository;
  bool loading = false;

  LoginController(this._context) {
    _userRepository = _context.read<UserRepository>();
  }

  Future<void> signIn() async {
    loading = true;
    notifyListeners();

    await _userRepository.login();

    loading = false;
    notifyListeners();
  }

}