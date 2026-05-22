import 'package:flutter/material.dart';
import 'package:naturats/components/challenge/category_tag.dart';
import 'package:naturats/components/challenge/challenge_impact_desc.dart';
import 'package:naturats/components/custom_dialog.dart';
import 'package:naturats/model/challenge.dart';
import 'package:naturats/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controller/challenges_controller.dart';

class DetailChallengeBox extends StatelessWidget {
  final Challenge challenge;

  const DetailChallengeBox({
    super.key,
    required this.challenge,
  });

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

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
            // cabeçalho
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
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CategoryTag(category: challenge.duration),
                          const SizedBox(width: 4),
                          CategoryTag(category: challenge.type),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Divider(color: AppColors.borderCinza, thickness: 1),

            // Conteúdo rolável
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      challenge.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Sobre o desafio",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                      map: challenge.statistics,
                    ),
                    const SizedBox(height: 20),

                    if (challenge.info != null && challenge.info!.isNotEmpty) ...[
                      const Text(
                        "Saiba mais",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.preto,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...challenge.info!.map(
                        (link) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: InkWell(
                            onTap: () => _launchUrl(link),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.link,
                                  size: 18,
                                  color: AppColors.buttomVerde,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    link,
                                    style: const TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: AppColors.buttomVerde,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),

            // botão adicionar
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
                          desc:
                              "Tem certeza de que deseja iniciar este desafio?",
                          primaryButtonText: "Confirmar",
                          primaryButtonColor: AppColors.bgVerde,
                          onConfirm: () {
                            controller.addChallengeToUserLibrary(challenge.id);
                          },
                        );
                      },
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
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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