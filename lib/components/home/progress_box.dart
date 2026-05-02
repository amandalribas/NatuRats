import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ProgressBox extends StatelessWidget {
  final int nextLevel;
  final int totalPoints;
  final int currentPoints;

  const ProgressBox({
    super.key,
    required this.nextLevel,
    required this.currentPoints,
    required this.totalPoints
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.branco.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Progresso para o nível ${nextLevel}",
                style: const TextStyle(color: AppColors.branco),
              ),
              Text(
                "$currentPoints/$totalPoints",
                style: const TextStyle(color: AppColors.branco),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: currentPoints/totalPoints,
              minHeight: 8,
              backgroundColor: Colors.white30,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}