import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:naturats/components/home/progress_box.dart';
import 'package:naturats/components/home/statistic_box.dart';
import '../../theme/app_colors.dart';
import '../../view/credits_page.dart';

class HomePageHeader extends StatelessWidget {
  final String name;

  const HomePageHeader({
    super.key,
    required this.name
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
              IconButton(
                  onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreditsPage(),
                        ),
                      );
                    },
                  icon: const Icon(
                    Icons.info_outline,
                    color: AppColors.branco,
                    size: 25,
                  )
              )
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
              Row(
                children: [
                  Expanded(child: StatisticBox(title: "Nível", value: 12)),
                  const SizedBox(width: 10),
                  Expanded(child: StatisticBox(title: "Pontos", value: 2450)),
                  const SizedBox(width: 10),
                  Expanded(child: StatisticBox(title: "Sequência", value: 16)),
                ],
              ),
              const SizedBox(height: 16),
              ProgressBox(nextLevel: 3, currentPoints: 2450, totalPoints: 3000),
            ],
          )
        ],
      ),
    );
  }
}