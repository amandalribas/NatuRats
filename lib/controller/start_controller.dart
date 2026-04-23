import 'package:flutter/material.dart';
import 'package:naturats/controller/login_controller.dart';
import 'package:naturats/repository/user_repository.dart';
import 'package:naturats/view/login_page.dart';
import 'package:naturats/view/splash_page.dart';
import 'package:naturats/view/tabs_page.dart';
import 'package:provider/provider.dart';

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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserRepository>(
      builder: (context, userRepository, child) {
        RedirectionData redirectionData = RedirectionData();
        redirectionData.signedIn = userRepository.isSignedIn;
        redirectionData.isLoading = userRepository.isLoading;

        return Builder(
          builder: (c) => handleRedirection(redirectionData),
        );
      },
    );
  }

  Widget handleRedirection(RedirectionData redirectionData) {
    if (redirectionData.isLoading) {
      return SplashPage();
    }

    if (!redirectionData.signedIn) {
      return LoginPage();
    }

    return TabsPage();
  }
}
