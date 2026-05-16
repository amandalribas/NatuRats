import 'package:flutter/material.dart';
import 'package:naturats/components/challenge/challenge_impact_desc.dart';
import 'package:naturats/model/challenge.dart';

class FinishChallengeDialog extends StatelessWidget {

  final int points;
  final Challenge challenge;

  const FinishChallengeDialog({
    super.key,
    required this.points,
    required this.challenge,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,

      child: Container(
        padding: const EdgeInsets.all(24),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 90,
              width: 90,

              decoration: BoxDecoration(
                color: Colors.green.shade600,
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 52,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Muito bem!",

              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Ação registrada com sucesso.",

              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 28),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: const Color(0xFFF4FAF4),
                borderRadius: BorderRadius.circular(22),
              ),

              child: Column(
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: [
                      Icon(
                        Icons.eco,
                        color: Colors.green.shade700,
                        size: 28,
                      ),

                      const SizedBox(width: 8),

                      Text(
                        "+$points pontos",

                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  ChallengeImpact(
                    map: challenge.statistics,
                  ),
                  /*
                  Text(
                    "aaa",

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                  */
                ],
              ),
            ),

            const SizedBox(height: 26),

            SizedBox(
              width: double.infinity,
              height: 56,

              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green.shade700,

                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                ),

                child: const Text(
                  "Continuar",

                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 56,

              child: OutlinedButton(
                onPressed: () {},

                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Colors.green.shade700,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                ),

                child: Text(
                  "Compartilhar com grupo",

                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  
}

