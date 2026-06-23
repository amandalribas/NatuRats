import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:naturats/repository/user_repository.dart';
import 'package:naturats/view/login_page.dart';
import 'package:naturats/view/splash_page.dart';
import 'package:naturats/view/tabs_page.dart';

class RedirectionData {
  bool signedIn;
  bool isLoading;

  RedirectionData({
    this.signedIn = false,
    this.isLoading = true,
  });
}

class StartController extends StatefulWidget {
  const StartController({super.key});

  @override
  State<StartController> createState() => _StartPageState();
}

class _StartPageState extends State<StartController> {
  late Future<void> _minimumSplashTime;

  @override
  void initState() {
    super.initState();

    _minimumSplashTime = Future.delayed(
      const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _minimumSplashTime,
      builder: (context, timerSnapshot) {
        if (timerSnapshot.connectionState != ConnectionState.done) {
          return const SplashPage();
        }

        return Consumer<UserRepository>(
          builder: (context, userRepository, child) {
            RedirectionData redirectionData = RedirectionData(
              signedIn: userRepository.isSignedIn,
              isLoading: userRepository.isLoading,
            );

            return handleRedirection(redirectionData);
          },
        );
      },
    );
  }

  Widget handleRedirection(RedirectionData redirectionData) {
    if (redirectionData.isLoading) {
      return const SplashPage();
    }

    if (!redirectionData.signedIn) {
      return const LoginPage();
    }

    // Obtém o repositório do usuário
    final userRepo = context.read<UserRepository>();

    return FutureBuilder<bool>(
      future: userRepo.isNewUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final showTutorial = snapshot.data ?? false;
        return TabsPage(showTutorial: showTutorial);
      },
    );
  }
}