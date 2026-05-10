import 'package:flutter/material.dart';
import 'package:naturats/components/challenge/category_tag.dart';
import 'package:naturats/components/challenge/challenge_impact_desc.dart';
import 'package:naturats/components/custom_dialog.dart';
import 'package:naturats/model/challenge.dart';
import 'package:naturats/theme/app_colors.dart';
import 'package:provider/provider.dart';

import '../controller/challenges_controller.dart';

class DetailChallengeBox extends StatelessWidget {
  final Challenge challenge;

  const DetailChallengeBox({
    super.key,
    required this.challenge
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ChallengesController>();

    return Scaffold(
      backgroundColor: AppColors.branco,
      appBar: AppBar(
        backgroundColor: AppColors.branco,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.preto),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //cabecalho
            Row(
              children: [
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: challenge.type.color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    challenge.type.icon,
                    size: 40,
                    color: AppColors.preto,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.preto,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ), // Aumentei um pouco o espaço para as tags
                      // --- TAGS DE CATEGORIA E SUB CATEGORIA ---
                      Row(
                        children: [
                          CategoryTag(category: challenge.duration),
                          const SizedBox(width: 4), // Espaço entre as tags
                          CategoryTag(category: challenge.type),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            //Divider(color: Colors.grey.withValues(alpha: 0.7)),
            Divider(color: AppColors.borderCinza, thickness: 1),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      challenge.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight:
                        FontWeight.bold,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Sobre o desafio",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                        FontWeight.bold,
                        color: AppColors.preto,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      challenge.details,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ChallengeImpact(
                      map: challenge.statistics!,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // botao adicionar
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return CustomDialog(
                          title: "Iniciar Desafio",
                          desc: "Tem certeza de que deseja iniciar este desafio?",
                          primaryButtonText: "Confirmar",
                          primaryButtonColor: AppColors.bgVerde,
                          onConfirm: () {
                            controller.addChallengeToUserLibrary(challenge.id);
                          }
                        );
                      }
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttomVerde,
                    foregroundColor: AppColors.branco,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Iniciar desafio",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
