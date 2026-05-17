import 'package:flutter/material.dart';
import 'package:naturats/theme/app_colors.dart';

class ChallengeCard extends StatelessWidget {
  final String eventTitle;
  final int? pointsEarned;
  final DateTime eventDate;

  const ChallengeCard({super.key, required this.eventTitle, required this.eventDate, this.pointsEarned});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Desafio concluído", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("+${pointsEarned ?? 0}pts", style: const TextStyle(color: AppColors.bgVerde, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(eventTitle)),
                const SizedBox(width: 12),
                Text("${eventDate.day}/${eventDate.month}/${eventDate.year}"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}