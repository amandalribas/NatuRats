import 'package:flutter/material.dart';
import 'package:naturats/controller/home_controller.dart';
import 'package:naturats/shared/components/progress_box.dart';
import 'package:provider/provider.dart';
import '../shared/components/statistic_box.dart';
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
          body: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                color: AppColors.bgVerde,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Olá, ${controller.name}!",
                          style: const TextStyle(
                            color: AppColors.branco,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                            onPressed: null,
                            icon: const Icon(
                              Icons.info_outline,
                              color: AppColors.branco,
                              size: 25,
                            )
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Continue fazendo a diferença",
                      style: TextStyle(
                        color: AppColors.branco,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: StatisticBox(title: "Nível", value: 12)),
                            const SizedBox(width: 10),
                            Expanded(child: StatisticBox(title: "Pontos", value: 2450)),
                            const SizedBox(width: 10),
                            Expanded(child: StatisticBox(title: "Sequência", value: 16)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ProgressBox(nextLevel: 3, currentPoints: 2450, totalPoints: 3000),
                      ],
                    )
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  width: double.infinity,
                  color: AppColors.branco,
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Desafios Ativos",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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