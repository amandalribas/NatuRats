import 'package:flutter/material.dart';
import 'package:naturats/controller/home_controller.dart';
import 'package:naturats/controller/profile_controller.dart';
import 'package:provider/provider.dart';
import '../../model/challenge.dart';
import 'active_challenge_box.dart';

class ActiveChallengesListWidget extends StatefulWidget {
  final Function(Challenge) onTap;
  final List<Challenge> challenges;
  final bool loading;
  //final ProfileController profileController;
  

  const ActiveChallengesListWidget({
    super.key,
    required this.onTap,
    required this.challenges,
    required this.loading,
    //required this.profileController,
  });

  @override
  State<ActiveChallengesListWidget> createState() =>
      _ActiveChallengesListWidgetState();
}

class _ActiveChallengesListWidgetState
    extends State<ActiveChallengesListWidget> {

  // progresso mockado
  final Map<String, int> progresses = {};

  @override
  void initState() {
    super.initState();

    // inicia todos com 0
    for (final challenge in widget.challenges) {
      progresses[challenge.id] = 0;
    }
  }

  void registerProgress(String challengeId) {
    setState(() {
      progresses[challengeId] =
          (progresses[challengeId] ?? 0) + 1;
    });
  }

  

  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (widget.challenges.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text(
            "Nenhum desafio ativo",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.only(
          top: 12,
          bottom: 24,
        ),

        itemCount: widget.challenges.length,

        separatorBuilder: (_, __) =>
            const SizedBox(height: 2),

        itemBuilder: (context, index) {
          final challenge =
              widget.challenges[index];

          final currentProgress =
              progresses[challenge.id] ?? 0;

          final int goal = challenge.goal;

          return ActiveChallengeBox(

            onCompleteChallenge: () {
              context
                  .read<HomeController>()
                  .completeChallenge(challenge);
            },

            challenge: challenge,

            currentProgress: currentProgress,

            goal: goal,

            onTap: () =>
                widget.onTap(challenge),

            onRegister: () {
              registerProgress(challenge.id);
            },

            onFinish: () async {
              await context
                  .read<HomeController>()
                  .completeChallenge(challenge);
            },
          );
        },
      ),
    );
  }
}