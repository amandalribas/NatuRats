import 'package:flutter/material.dart';
import 'package:naturats/components/challenge/challenge_header.dart';
import 'package:naturats/components/challenge/challenges_list.dart';
import 'package:naturats/components/challenge/filter_box.dart';
import 'package:naturats/controller/challenges_controller.dart';
import 'package:naturats/theme/app_colors.dart';
import 'package:provider/provider.dart';

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
        return Scaffold(
          backgroundColor: AppColors.bgCinza,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChallengeHeader(),
              const FilterBox(),
              ChallengesListWidget(
                  onTap: (challenge) {
                    controller.onTapChallengeBox(
                      challenge,
                    );
                  },
                  challenges: controller.filteredChallenges,
                  loading: controller.loading
              )
            ],
          ),
        );
      }
    );
  }
}
