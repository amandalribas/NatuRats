import 'package:flutter/material.dart';

class GroupDetailsHeader extends StatelessWidget {
  final String name;
  final String imageUrl;
  final int people;
  final int points;

  const GroupDetailsHeader({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.people,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // IMAGEM
        SizedBox(
          height: 180,
          width: double.infinity,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
          ),
        ),

        // ESCURECER
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.45),
          ),
        ),

        // BOTÃO VOLTAR
        SafeArea(
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),

        // TEXTO
        Positioned(
          left: 16,
          bottom: 30,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Row(
                children: [
                  const Icon(Icons.group,
                      color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    "$people",
                    style: const TextStyle(color: Colors.white),
                  ),

                  const SizedBox(width: 12),

                  const Icon(Icons.emoji_events,
                      color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    "$points",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}