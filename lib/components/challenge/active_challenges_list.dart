import 'package:flutter/material.dart';
import 'package:naturats/controller/home_controller.dart';
import 'package:provider/provider.dart';
import '../../model/challenge.dart';
import 'active_challenge_box.dart';
import 'package:naturats/view/challenge_active_detail_page.dart';
import 'package:naturats/view/finish_challenge_dialog.dart';

class ActiveChallengesListWidget extends StatefulWidget {
  final Function(Challenge) onTap;
  final List<Challenge> challenges;
  final bool loading;

  const ActiveChallengesListWidget({
    super.key,
    required this.onTap,
    required this.challenges,
    required this.loading,
  });

  @override
  State<ActiveChallengesListWidget> createState() =>
      _ActiveChallengesListWidgetState();
}

class _ActiveChallengesListWidgetState
    extends State<ActiveChallengesListWidget> {
  
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeController>();

    if (widget.loading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    if (widget.challenges.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text(
            "Nenhum desafio ativo",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        itemCount: widget.challenges.length,
        separatorBuilder: (_, __) => const SizedBox(height: 2),
        itemBuilder: (context, index) {
          final challenge = widget.challenges[index];
          final currentProgress = controller.getProgress(challenge.id);
          final goal = challenge.goal;

          return ActiveChallengeBox(
            challenge: challenge,
            currentProgress: currentProgress,
            goal: goal,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ActiveChallengeDetailPage(
                    challenge: challenge,
                    currentProgress: currentProgress,
                    goal: goal,
                    onRegister: () => controller.incrementProgress(challenge),
                    onFinish: () async {
                      await controller.completeChallenge(challenge);
                      await showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => FinishChallengeDialog(
                          challenge: challenge,
                          points: challenge.duration.points,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
            onRegister: () => controller.incrementProgress(challenge),
            onFinish: () async {
              await controller.completeChallenge(challenge);
              await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => FinishChallengeDialog(
                  challenge: challenge,
                  points: challenge.duration.points,
                ),
              );
            },
          );
        },
      ),
    );
  }
}