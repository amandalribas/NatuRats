import 'package:flutter/material.dart';
import 'package:naturats/components/challenge/challenge_header.dart';
import 'package:naturats/components/challenge/challenges_list.dart';
import 'package:naturats/components/challenge/filter_box.dart';
import 'package:naturats/controller/challenges_controller.dart';
import 'package:naturats/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

class ChallengesPage extends StatelessWidget {
  final GlobalKey? filterKey;
  final GlobalKey? listKey;

  const ChallengesPage({super.key, this.filterKey, this.listKey});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChallengesController(context),
      child: _ChallengesView(filterKey: filterKey, listKey: listKey),
    );
  }
}

class _ChallengesView extends StatelessWidget {
  final GlobalKey? filterKey;
  final GlobalKey? listKey;

  const _ChallengesView({this.filterKey, this.listKey});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChallengesController>(
      builder: (context, controller, child) {
        final list = ChallengesListWidget(
          onTap: (challenge) {
            controller.onTapChallengeBox(challenge);
          },
          challenges: controller.filteredChallenges,
          loading: controller.loading,
        );

        return Scaffold(
          backgroundColor: AppColors.branco,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChallengeHeader(),
              FilterBox(showcaseKey: filterKey),
              Expanded(
                child: listKey == null
                    ? list
                    : Showcase(
                        key: listKey!,
                        title: "Lista de desafios",
                        description:
                            "Aqui ficam todos os desafios disponíveis. Toque em qualquer um deles para ver os detalhes e participar.",
                        overlayColor: AppColors.bgVerde.withOpacity(0.85),
                        overlayOpacity: 0.85,
                        titleTextStyle: const TextStyle(
                          color: AppColors.preto,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        descTextStyle: const TextStyle(
                          color: AppColors.textCinza,
                          fontSize: 14,
                          height: 1.5,
                        ),
                        tooltipBackgroundColor: Colors.white,
                        tooltipBorderRadius: BorderRadius.circular(20),
                        tooltipPadding: const EdgeInsets.all(20),
                        child: list,
                      ),
              ),
            ],
          ),
        );
      }
    );
  }
}