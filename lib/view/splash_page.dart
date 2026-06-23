import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bgVerde,
      body: Center(
        child: Image(
          image: AssetImage('assets/logo.png'),
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}