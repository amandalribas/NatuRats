import 'package:flutter/material.dart';
import 'package:naturats/controller/home_controller.dart';
import 'package:provider/provider.dart';
import '../../model/challenge.dart';
import 'active_challenge_box.dart';
import 'package:naturats/view/challenge_active_detail_page.dart';
import 'package:naturats/utils/dialog_utils.dart';

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
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.challenges.isEmpty) {
      return const Center(
        child: Text(
          "Nenhum desafio ativo",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      itemCount: widget.challenges.length,
      separatorBuilder: (_, __) => const SizedBox(height: 2),
      itemBuilder: (_, index) {
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
                builder: (pageContext) => ActiveChallengeDetailPage(
                  challenge: challenge,
                  currentProgress: currentProgress,
                  goal: goal,
                  onRegister: () => controller.incrementProgress(challenge),
                  onFinish: () async {
                    // pop já é feito dentro de ActiveChallengeDetailPage
                    // antes de chamar onFinish, então aqui só concluímos
                    // e exibimos o diálogo de parabéns.
                    await controller.completeChallenge(challenge);
                    DialogUtils.showFinishChallengeDialog(challenge);
                  },
                ),
              ),
            );
          },
          onRegister: () => controller.incrementProgress(challenge),
          onFinish: () async {
            await controller.completeChallenge(challenge);
            DialogUtils.showFinishChallengeDialog(challenge);
          },
        );
      },
    );
  }
}