import 'package:flutter/material.dart';

import '../../model/medal.dart';

class MedalCard extends StatelessWidget {
  const MedalCard({super.key, required this.medal, required this.color});

  final Medal medal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    //Se medalha bloqueada:
    final Color activeColor = medal.isUnlocked ? color : Colors.grey.shade400;
    final double textOpacity = medal.isUnlocked ? 0.6 : 0.4;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: activeColor, width: 3),
        borderRadius: BorderRadius.circular(20),
        boxShadow: medal.isUnlocked
            ? [
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: activeColor,
              shape: BoxShape.circle,
            ),
            child: Icon(medal.getIcon(), color: Colors.white, size: 36),
          ),
          const SizedBox(height: 12),
          Text(
            medal.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: medal.isUnlocked ? Colors.black87 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            medal.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black.withOpacity(0.6),
              fontStyle: medal.isUnlocked ? FontStyle.normal : FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
