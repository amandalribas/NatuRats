import 'package:flutter/material.dart';
import '../../model/challenge.dart';
import 'challenge_box.dart';

class ChallengesListWidget extends StatelessWidget {
  final Function(Challenge) onTap;
  final List<Challenge> challenges;
  final bool loading;

  const ChallengesListWidget({
    super.key,
    required this.onTap,
    required this.challenges,
    required this.loading
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: loading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : challenges.isEmpty
          ? const Center(
        child: Text("Nenhum desafio encontrado"),
      )
          : ListView.builder(
        itemCount: challenges.length,
        itemBuilder: (context, index) {
          final challenge =
          challenges[index];
          return ChallengeBox(
            challenge: challenge,
            onTap: () {
              onTap(challenge);
            },
          );
        },
      ),
    );
  }
}