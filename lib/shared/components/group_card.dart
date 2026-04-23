import 'package:flutter/material.dart';
import 'package:naturats/theme/app_colors.dart';

class Group extends StatelessWidget {
  final String id;
  final String name;
  final String description;
  final int totalPeople;
  final int totalPoints;
  final String imageUrl;

  const Group({
    super.key,
    required this.id,
    required this.name,
    required this.description,
    required this.totalPeople,
    required this.totalPoints,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        color: AppColors.branco,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.preto.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
            child: Image.network(
              imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  description,
                  style: TextStyle(color: AppColors.borderCinza),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    _buildInfoItem(Icons.people_outline, totalPeople),
                    const SizedBox(width: 20),
                    _buildInfoItem(Icons.emoji_events_outlined, totalPoints),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, int value) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 6),
        Text(value.toString()),
      ],
    );
  }
}