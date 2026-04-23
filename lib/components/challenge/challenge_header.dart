import 'package:flutter/material.dart';
import 'package:naturats/theme/app_colors.dart';

class ChallengeHeader extends StatelessWidget {
  const ChallengeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      width: double.infinity,
      decoration: BoxDecoration(color: AppColors.bgVerde),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //SizedBox(height: 20),
            Text(
              "Desafios Disponíveis",
              style: TextStyle(
                color: AppColors.branco,
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
            Text(
              "Clique em um desafio de interesse para saber mais e adicionar ao seu perfil.",
              style: TextStyle(
                color: AppColors.branco, fontSize: 16
                ),
            ),
          ],
        ),
      ),
    );
  }
}
