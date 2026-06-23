import 'package:flutter/material.dart';
import 'package:naturats/components/challenge/active_challenges_list.dart';
import 'package:naturats/components/home/home_header.dart';
import 'package:naturats/controller/home_controller.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import '../theme/app_colors.dart';

class HomePage extends StatelessWidget {
  final GlobalKey? statsKey;
  final GlobalKey? challengesKey;

  const HomePage({super.key, this.statsKey, this.challengesKey});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeController(context),
      child: _HomeView(statsKey: statsKey, challengesKey: challengesKey),
    );
  }
}

class _HomeView extends StatelessWidget {
  final GlobalKey? statsKey;
  final GlobalKey? challengesKey;

  const _HomeView({this.statsKey, this.challengesKey});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: AppColors.branco,
          body: Column(
            children: [
              HomePageHeader(
                name: controller.firstName!,
                level: controller.level,
                points: controller.numPoints,
                streak: controller.streak,
                statsKey: statsKey,
              ),
              SizedBox(
                width: double.infinity,
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Text(
                    "Desafios Ativos",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: _ShowcaseOrPlain(
                  showcaseKey: challengesKey,
                  title: "Desafios ativos",
                  description: "Aqui aparecem os desafios que você já começou. Toque em um deles para ver o progresso e concluí-lo.",
                  child: ActiveChallengesListWidget(
                    onTap: (_) {},
                    challenges: controller.activeChallenges,
                    loading: controller.loading,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ShowcaseOrPlain extends StatelessWidget {
  final GlobalKey? showcaseKey;
  final String title;
  final String description;
  final Widget child;

  const _ShowcaseOrPlain({
    required this.showcaseKey,
    required this.title,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (showcaseKey == null) return child;
    return Showcase(
      key: showcaseKey!,
      title: title,
      description: description,
      overlayColor: AppColors.bgVerde.withOpacity(0.85),
      overlayOpacity: 0.85,
      titleTextStyle: const TextStyle(color: AppColors.preto, fontSize: 20, fontWeight: FontWeight.bold),
      descTextStyle: const TextStyle(color: AppColors.textCinza, fontSize: 14, height: 1.5),
      tooltipBackgroundColor: Colors.white,
      tooltipBorderRadius: BorderRadius.circular(20),
      tooltipPadding: const EdgeInsets.all(20),
      child: child,
    );
  }
}