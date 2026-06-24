import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:naturats/model/group_model.dart';
import 'package:naturats/repository/group_repository.dart';
import 'package:naturats/theme/app_colors.dart';
import 'package:naturats/view/group_feed_rank_page.dart';
import 'package:naturats/view/group_join_page.dart';
import 'package:naturats/utils/base64_image.dart';

class GroupCard extends StatelessWidget {
  final GroupModel group;
  final VoidCallback? onReturn;

  const GroupCard({
    super.key,
    required this.group,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final imageBytes = decodeBase64Image(group.image);

    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          final groupRepository = GroupRepository();
          final userEmail = FirebaseAuth.instance.currentUser?.email;

          if (userEmail == null) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupJoinPage(group: group),
              ),
            );
            onReturn?.call();
            return;
          }

          final isMember =
              await groupRepository.isUserMember(group.id, userEmail);

          if (!context.mounted) return;

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => isMember
                  ? GroupFeedRankPage(
                      id: group.id,
                      name: group.name,
                      description: group.description,
                      totalPeople: group.totalPeople,
                      totalPoints: group.totalPoints,
                      imageUrl: group.image,
                    )
                  : GroupJoinPage(group: group),
            ),
          );

          onReturn?.call();
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
                        _buildInfoItem(
                            Icons.people_outline, group.totalPeople),
                        const SizedBox(width: 20),
                        _buildInfoItem(
                            Icons.emoji_events_outlined, group.totalPoints),
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
        Text(value.toString(), style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}