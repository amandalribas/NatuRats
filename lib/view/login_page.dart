import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_button/constants.dart';
import 'package:sign_button/create_button.dart';
import '../controller/login_controller.dart';
import '../theme/app_colors.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginController(context),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: AppColors.bgVerde,
          body: Center(
            child: !controller.loading
                ? Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Bem-vindo!",
                  style: TextStyle(
                    color: AppColors.branco,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),
                SignInButton(
                  buttonType: ButtonType.googleDark,
                  btnText: "Entrar com o Google",
                  onPressed: () {
                    controller.signIn();
                  },
                ),
              ],
            )
                : const CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
