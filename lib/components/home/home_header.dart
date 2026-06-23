import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:naturats/components/home/progress_box.dart';
import 'package:naturats/components/home/statistic_box.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../theme/app_colors.dart';

class HomePageHeader extends StatelessWidget {
  final String name;
  final int points;
  final int level;
  final int streak;
  final GlobalKey? statsKey;

  const HomePageHeader({
    super.key,
    required this.name,
    required this.points,
    required this.level,
    required this.streak,
    this.statsKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      color: AppColors.bgVerde,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Olá, $name!",
                style: const TextStyle(
                  color: AppColors.branco,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Continue fazendo a diferença",
            style: TextStyle(
              color: AppColors.branco,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          Column(
            children: [
              _statsRow(),
              const SizedBox(height: 16),
              ProgressBox(nextLevel: (level + 1), currentPoints: points, totalPoints: (level * 50)),
            ],
          )
        ],
      ),
    );
  }

  Widget _statsRow() {
    final row = Row(
      children: [
        Expanded(child: StatisticBox(title: "Nível", value: level)),
        const SizedBox(width: 10),
        Expanded(child: StatisticBox(title: "Pontos", value: (points + (level * (level - 1) * 25)))),
        const SizedBox(width: 10),
        Expanded(child: StatisticBox(title: "Sequência", value: streak)),
      ],
    );

    if (statsKey == null) return row;

    return Showcase(
      key: statsKey!,
      title: "Seu progresso",
      description: "Aqui você vê seu nível atual, sua pontuação total e sua sequência de dias ativos no app.",
      overlayColor: AppColors.bgVerde.withOpacity(0.85),
      overlayOpacity: 0.85,
      titleTextStyle: const TextStyle(color: AppColors.preto, fontSize: 20, fontWeight: FontWeight.bold),
      descTextStyle: const TextStyle(color: AppColors.textCinza, fontSize: 14, height: 1.5),
      tooltipBackgroundColor: Colors.white,
      tooltipBorderRadius: BorderRadius.circular(20),
      tooltipPadding: const EdgeInsets.all(20),
      child: row,
    );
  }
}