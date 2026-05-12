import 'package:flutter/material.dart';
import 'package:naturats/components/challenge/active_challenges_list.dart';
import 'package:naturats/components/home/home_header.dart';
import 'package:naturats/controller/home_controller.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeController(context),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    
    return Consumer<HomeController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: AppColors.bgCinza,
          body: Column(
            children: [
              HomePageHeader(name: controller.firstName!, level: controller.level, points: controller.numPoints, streak: controller.streak),
              SizedBox(
                width: double.infinity,
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Text(
                    "Desafios Ativos",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ActiveChallengesListWidget(

                  onTap: (challenge) {
                    // TODO
                  },
                  challenges: controller.activeChallenges,
                  loading: controller.loading
              )
            ],
          ),
        );
      },
    );
  }
}