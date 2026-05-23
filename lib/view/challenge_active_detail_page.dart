import 'package:flutter/material.dart';
import 'package:naturats/components/challenge/category_tag.dart';
import 'package:naturats/components/challenge/challenge_impact_desc.dart';
import 'package:naturats/model/challenge.dart';
import 'package:naturats/theme/app_colors.dart';
import 'package:naturats/view/finish_challenge_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class ActiveChallengeDetailPage extends StatelessWidget {
  final Challenge challenge;
  final int currentProgress;
  final int goal;
  final VoidCallback onRegister;
  final VoidCallback onFinish;

  const ActiveChallengeDetailPage({
    super.key,
    required this.challenge,
    required this.currentProgress,
    required this.goal,
    required this.onRegister,
    required this.onFinish,
  });

  double get progress => currentProgress / goal;
  bool get canFinish => currentProgress >= goal - 1;
  String get progressText => "$currentProgress/$goal concluído";


  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.branco,
      body: Column(
        children: [
          // ── Header verde ───────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: AppColors.bgVerde),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.branco,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        height: 58,
                        width: 58,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          challenge.type.icon,
                          size: 30,
                          color: AppColors.branco,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          challenge.title,
                          style: const TextStyle(
                            color: AppColors.branco,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      CategoryTag(category: challenge.duration),
                      CategoryTag(category: challenge.type),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descrição curta
                  const Text(
                    "Sobre o desafio",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.preto,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    challenge.description,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),

                  // Detalhes (campo "details", se diferente da descrição)
                  if (challenge.details.isNotEmpty &&
                      challenge.details != challenge.description) ...[
                    const SizedBox(height: 16),
                    Text(
                      challenge.details,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Dicas / info
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

                  // Impacto ambiental (statistics)
                  if (challenge.statistics.isNotEmpty) ...[
                    ChallengeImpact(map: challenge.statistics),
                    const SizedBox(height: 24),
                  ],

                  // Progresso
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Seu progresso",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.preto,
                        ),
                      ),
                      Text(
                        progressText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: challenge.type.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress > 1 ? 1 : progress,
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        challenge.type.color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "${(progress * 100).clamp(0, 100).toInt()}%",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Pontos
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Colors.amber.shade600,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "${challenge.duration.points} pontos ao concluir",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botão principal
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (canFinish) {
                          onFinish();
                          Navigator.of(context).pop();
                          await showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => FinishChallengeDialog(
                              challenge: challenge,
                              points: challenge.duration.points,
                            ),
                          );
                        } else {
                          onRegister();
                          Navigator.of(context).pop();
                        }
                      },
                      icon: Icon(
                        canFinish ? Icons.check_circle_outline : Icons.add,
                        size: 22,
                      ),
                      label: Text(
                        canFinish ? "Completar missão" : "Registrar progresso",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canFinish
                            ? Colors.green.shade600
                            : AppColors.bgVerde,
                        foregroundColor: AppColors.branco,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
