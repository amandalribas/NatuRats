import 'package:flutter/material.dart';
import 'package:naturats/theme/app_colors.dart';

class FeedCard extends StatelessWidget {
  final String userName;
  final String missionName;
  final String? photoUrl;

  const FeedCard({
    super.key,
    required this.userName,
    required this.missionName,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: AppColors.branco,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.bgCinza,

            backgroundImage:
                photoUrl != null && photoUrl!.isNotEmpty
                    ? NetworkImage(photoUrl!)
                    : null,

            child: photoUrl == null || photoUrl!.isEmpty
                ? const Icon(Icons.person)
                : null,
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "Concluiu a missão '$missionName'",
                  style: const TextStyle(
                    color: AppColors.borderCinza,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}