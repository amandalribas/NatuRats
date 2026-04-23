import 'package:flutter/material.dart';
import 'package:naturats/theme/app_colors.dart';

class PostCard extends StatelessWidget {
  final String userName;
  final String message;
  final String? imageUrl;

  const PostCard({
    super.key,
    required this.userName,
    required this.message,
    this.imageUrl,
  });

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.branco,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: ListTile(
            leading: const Icon(
              Icons.report,
              color: AppColors.vermelho,
            ),
            title: const Text("Denunciar usuário"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 16,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.branco,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            blurRadius: 4,
            offset: Offset(0, 2),
            color: Colors.black12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOPO: FOTO + NOME + MENU
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.bgCinza,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.preto,
                  ),
                ),
              ),

              IconButton(
                icon: const Icon(Icons.more_horiz),
                onPressed: () => _showMenu(context),
              ),
            ],
          ),

          /// TEXTO EMBAIXO
          const SizedBox(height: 8),

          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.preto,
            ),
          ),

          /// IMAGEM EMBAIXO
          if (imageUrl != null) ...[
            const SizedBox(height: 12),

            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ],
      ),
    );
  }
}