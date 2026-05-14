import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:naturats/model/group_model.dart';
import 'package:naturats/theme/app_colors.dart';
import 'package:naturats/view/group_feed_rank_page.dart';

class GroupCard extends StatelessWidget {
  final GroupModel group;

  const GroupCard({
    super.key,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    final imageBytes = _decodeBase64Image(group.image);

    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupFeedRankPage(
                id: group.id,
                name: group.name,
                description: group.description,
                totalPeople: group.totalPeople,
                totalPoints: group.totalPoints,
                imageUrl: group.image,
              ),
            ),
          );
        },

        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          margin: const EdgeInsets.symmetric(vertical: 15),
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
                child: imageBytes != null
                    ? Image.memory(
                        imageBytes,
                        height: 130,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 130,
                        width: double.infinity,
                        color: AppColors.borderCinza.withOpacity(0.15),
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_outlined),
                      ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      group.description,
                      style: TextStyle(color: AppColors.borderCinza),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        _buildInfoItem(Icons.people_outline, group.totalPeople),
                        const SizedBox(width: 20),
                        _buildInfoItem(Icons.emoji_events_outlined, group.totalPoints),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, int value) {
    return Row(
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 6),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Uint8List? _decodeBase64Image(String value) {
    if (value.isEmpty) {
      return null;
    }

    final normalizedValue = value.contains(',') ? value.split(',').last : value;

    try {
      return base64Decode(normalizedValue);
    } catch (_) {
      return null;
    }
  }
}