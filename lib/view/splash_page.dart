import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgVerde,
      body: const Center(
        child: Text(
          'NatuRats',
          style: TextStyle(
            color: AppColors.branco,
            fontSize: 50,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}