import 'package:flutter/material.dart';
import 'package:naturats/components/challenge/challenge_box.dart';
import 'package:naturats/components/challenge/challenge_header.dart';
import 'package:naturats/components/challenge/filter_box.dart';
import 'package:naturats/controller/challenges_controller.dart';
import 'package:naturats/theme/app_colors.dart';
import 'package:provider/provider.dart';

import '../model/challenge.dart';

class ChallengesPage extends StatelessWidget {
  const ChallengesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChallengesController(context),
      child: const _ChallengesView(),
    );
  }
}

class _ChallengesView extends StatelessWidget {
  const _ChallengesView();

  @override
  Widget build(BuildContext context) {
    return Consumer<ChallengesController>(
      builder: (context, controller, child) {
        List<Challenge> challenges = controller.getFilteredChallenges();

        return Scaffold(
          backgroundColor: AppColors.bgCinza,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChallengeHeader(),
              const FilterBox(),
              Expanded(
                child: controller.loading
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
                        controller.onTapChallengeBox(
                          challenge,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}
