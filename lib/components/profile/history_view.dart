import 'package:flutter/material.dart';
import 'package:naturats/components/profile/completed_challenge_card.dart';
import 'package:naturats/model/completed_challenges.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key, required this.completedChallenges});

  final List<CompletedChallenges> completedChallenges;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: completedChallenges.length,
      itemBuilder: (context, index) {
        final challenge = completedChallenges[index];
        return ChallengeCard(
          eventTitle: challenge.title,
          eventDate: challenge.completedAt,
          pointsEarned: challenge.points,
        );
      },
    );
  }
}
