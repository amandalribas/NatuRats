import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:naturats/theme/app_colors.dart';

class GroupDetailPage extends StatelessWidget {
  final String id;
  final String name;
  final String description;
  final int totalPeople;
  final int totalPoints;
  final String imageUrl;

  const GroupDetailPage({
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
    final imageBytes = _decodeBase64Image(imageUrl);

    return Scaffold(
      backgroundColor: AppColors.branco,

      body: Column(
        children: [

          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 35, 20, 5),
            color: AppColors.bgVerde,

            child: Row(
              children: [
                // botão voltar
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: AppColors.branco),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: AppColors.branco,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          ClipRRect(
            child: imageBytes != null
                ? Image.memory(
                    imageBytes,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 150,
                    width: double.infinity,
                    color: AppColors.borderCinza.withOpacity(0.15),
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_outlined),
                  ),
          ),
        ],
      ),
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