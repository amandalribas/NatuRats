import 'package:flutter/material.dart';

class ChallengeImpact extends StatelessWidget {
  final Map<String, dynamic> map;

  const ChallengeImpact({
    super.key,
    required this.map
  });

  @override
  Widget build(BuildContext context) {
    final List<String> impacts = [];

    if (map["water"] != null) {
      impacts.add(
        "${map["water"]} litros de água economizados.",
      );
    }

    if (map["CO2"] != null) {
      impacts.add(
        "${map["CO2"]} gramas de CO₂ reduzidos.",
      );
    }

    if (map["recycled"] != null) {
      impacts.add(
        "${map["recycled"]} itens reciclados.",
      );
    }

    if (map["km"] != null) {
      impacts.add(
        "${map["km"]} km de transporte sustentável.",
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Impacto",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...impacts.map(
              (impact) => Padding(
            padding: const EdgeInsets.only(
              bottom: 4,
            ),

            child: Text(
              "• $impact",
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}