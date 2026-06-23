import 'package:flutter/material.dart';
import 'package:naturats/components/profile/top_stat_card.dart';
import 'package:naturats/components/profile/view_selector.dart';
import 'package:naturats/controller/profile_controller.dart';
import 'package:naturats/theme/app_colors.dart';
import 'package:naturats/view/config_page.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

class ProfilePage extends StatelessWidget {
  final GlobalKey? settingsKey;
  final GlobalKey? statTabsKey;

  const ProfilePage({super.key, this.settingsKey, this.statTabsKey});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileController(context),
      child: _ProfileView(settingsKey: settingsKey, statTabsKey: statTabsKey),
    );
  }
}

class _ProfileView extends StatefulWidget {
  final GlobalKey? settingsKey;
  final GlobalKey? statTabsKey;

  const _ProfileView({this.settingsKey, this.statTabsKey});

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  int _selectedIndex = 0;
  final List<String> _tabs = ['Estatísticas', 'Medalhas', 'Histórico'];

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: AppColors.branco,
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
                      children: [
                        CircleAvatar(
                          backgroundImage: controller.getProfilePic(),
                          backgroundColor: Colors.white24,
                          child: controller.getProfilePic() == null
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            controller.fullName ?? 'Usuário',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        widget.settingsKey == null
                            ? IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ConfigPage(),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.settings,
                                  color: AppColors.branco,
                                  size: 25,
                                ),
                              )
                            : Showcase(
                                key: widget.settingsKey!,
                                title: "Configurações",
                                description:
                                    "Toque aqui para acessar as configurações da sua conta, como dados pessoais, notificações e logout.",
                                targetShapeBorder: const CircleBorder(),
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
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const ConfigPage(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.settings,
                                    color: AppColors.branco,
                                    size: 25,
                                  ),
                                ),
                              ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 55),
                      child: Text(
                        'Nível ${controller.getUserLevel()} • ${controller.getUserPoints() + (controller.getUserLevel() * (controller.getUserLevel() - 1) * 25)} pontos',
                        style: const TextStyle(
                          color: AppColors.branco,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: StreamBuilder(
                            stream: controller.getUnlockedMedalsCountStream(),
                            builder: (context, snapshot) {
                              final int count =
                                  snapshot.data ?? controller.getTotalMedals();
                              return TopStatCard(
                                title: 'Medalhas',
                                value: '$count',
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TopStatCard(
                            title: 'Sequência',
                            value: '${controller.getSequence()}',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TopStatCard(
                            title: 'Desafios',
                            value: '${controller.getTotalChallenges()}',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              _statTabsRow(),
              ViewSelector(selectedIndex: _selectedIndex),
            ],
          ),
        );
      },
    );
  }

  Widget _statTabsRow() {
    final row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedIndex == index;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : 5,
                right: index == _tabs.length - 1 ? 0 : 5,
              ),
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: isSelected
                      ? AppColors.buttomVerde
                      : Colors.transparent,
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.buttomVerde
                        : Colors.grey.shade400,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 0,
                  ),
                ),
                child: Text(
                  _tabs[index],
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );

    if (widget.statTabsKey == null) return row;

    return Showcase(
      key: widget.statTabsKey!,
      title: "Estatísticas, Medalhas e Histórico",
      description:
          "Alterne entre suas estatísticas gerais, as medalhas conquistadas e o histórico de desafios concluídos.",
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
      child: row,
    );
  }
}