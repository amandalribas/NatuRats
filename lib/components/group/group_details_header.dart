import 'dart:convert';
import 'package:flutter/material.dart';

class GroupDetailsHeader extends StatelessWidget {
  final String name;
  final String imageUrl;
  final int people;
  final int points;
  final VoidCallback? onInvite;

  const GroupDetailsHeader({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.people,
    required this.points,
    this.onInvite,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // IMAGEM (suporta URL ou base64). Reduz decode via cacheWidth/cacheHeight e mostra placeholder em erro.
        SizedBox(
          height: 180,
          width: double.infinity,
          child: Builder(builder: (context) {
            try {
              final isDataUri = imageUrl.startsWith('data:image');
              final isBase64 = isDataUri || imageUrl.contains(RegExp(r'^[A-Za-z0-9+/=\s]+$')) && imageUrl.length > 200;

              if (isDataUri || isBase64) {
                final comma = imageUrl.indexOf(',');
                final payload = comma != -1 ? imageUrl.substring(comma + 1) : imageUrl;
                final bytes = base64Decode(payload);
                return Image.memory(
                  bytes,
                  fit: BoxFit.cover,
                  // request a smaller decoded image to save memory/time
                  cacheWidth: 1200,
                  filterQuality: FilterQuality.low,
                  errorBuilder: (context, error, stack) => Container(color: Colors.grey[300]),
                );
              }
              // Não usamos imagens remotas; se não for base64, mostrar placeholder
              return Container(color: Colors.grey[300]);
            } catch (_) {
              return Container(color: Colors.grey[300]);
            }
          }),
        ),

        // ESCURECER
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: Color.fromRGBO(0, 0, 0, 0.45),
          ),
        ),

        // BOTÃO VOLTAR + CONVIDAR
        SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              if (onInvite != null)
                IconButton(
                  icon: const Icon(
                    Icons.person_add,
                    color: Colors.white,
                  ),
                  onPressed: onInvite,
                ),
            ],
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