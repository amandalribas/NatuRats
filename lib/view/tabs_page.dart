import 'package:flutter/material.dart';
import 'package:naturats/theme/app_colors.dart';
import 'package:naturats/service/tutorial_service.dart';
import 'package:showcaseview/showcaseview.dart';
import 'challenges_page.dart';
import 'home_page.dart';
import 'package:naturats/view/groups_page.dart';
import 'package:naturats/view/profile_page.dart';

class TabsPage extends StatefulWidget {
  final bool showTutorial;
  const TabsPage({super.key, this.showTutorial = false});
  

  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Chaves
  final GlobalKey _homeTabKey = GlobalKey();
  final GlobalKey _challengesTabKey = GlobalKey();
  final GlobalKey _groupsTabKey = GlobalKey();
  final GlobalKey _profileTabKey = GlobalKey();
  final GlobalKey _homeStatsKey = GlobalKey();
  final GlobalKey _homeChallengesKey = GlobalKey();
  final GlobalKey _filterKey = GlobalKey();
  final GlobalKey _challengesListKey = GlobalKey();
  final GlobalKey _groupsFabKey = GlobalKey();
  final GlobalKey _groupsSearchKey = GlobalKey();
  final GlobalKey _groupsTabsKey = GlobalKey();
  final GlobalKey _profileSettingsKey = GlobalKey();
  final GlobalKey _profileStatTabsKey = GlobalKey();

  late final List<_TutorialStep> _steps = [
    _TutorialStep(tabIndex: 0, keys: [_homeTabKey, _homeStatsKey, _homeChallengesKey]),
    _TutorialStep(tabIndex: 1, keys: [_challengesTabKey, _filterKey, _challengesListKey]),
    _TutorialStep(tabIndex: 2, keys: [_groupsTabKey, _groupsFabKey, _groupsSearchKey, _groupsTabsKey]),
    _TutorialStep(tabIndex: 3, keys: [_profileTabKey, _profileSettingsKey, _profileStatTabsKey]),
  ];

  int _currentStep = 0;
  bool _tutorialRunning = false;
  BuildContext? _showcaseContext;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStartTutorial());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _maybeStartTutorial() async {
  if (!widget.showTutorial || !mounted) return;
  _tutorialRunning = true;
  _currentStep = 0;
  _runCurrentStep();
}

  void _runCurrentStep() {
    if (!mounted || _currentStep >= _steps.length) return;
    final step = _steps[_currentStep];
    _tabController.animateTo(step.tabIndex);

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted || _showcaseContext == null) return;
      ShowCaseWidget.of(_showcaseContext!).startShowCase(step.keys);   // ← CORRETO
    });
  }

  void _onStepFinished() {
    if (!_tutorialRunning) return;
    _currentStep++;
    if (_currentStep < _steps.length) {
      _runCurrentStep();
    } else {
      _tutorialRunning = false;
      TutorialService.setTutorialSeen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      onFinish: _onStepFinished,
      blurValue: 2,
      autoPlay: false,
      enableShowcase: true,
      builder: (builderContext) {
        _showcaseContext = builderContext;

        final pages = [
          HomePage(statsKey: _homeStatsKey, challengesKey: _homeChallengesKey),
          ChallengesPage(filterKey: _filterKey, listKey: _challengesListKey),
          GroupPage(fabKey: _groupsFabKey, searchKey: _groupsSearchKey, tabsKey: _groupsTabsKey),
          ProfilePage(settingsKey: _profileSettingsKey, statTabsKey: _profileStatTabsKey),
        ];

        final tabs = [
          Tab(
            icon: _buildShowcaseIcon(
              key: _homeTabKey,
              title: "Início",
              description: "Acompanhe seu nível, pontos, sequência e desafios ativos.",
              icon: Icons.home_filled,
            ),
            text: "Início",
          ),
          Tab(
            icon: _buildShowcaseIcon(
              key: _challengesTabKey,
              title: "Desafios",
              description: "Lista de todos os desafios disponíveis. Toque em um para detalhes.",
              icon: Icons.workspace_premium,
            ),
            text: "Desafios",
          ),
          Tab(
            icon: _buildShowcaseIcon(
              key: _groupsTabKey,
              title: "Grupos",
              description: "Participe de grupos e enfrente desafios em equipe.",
              icon: Icons.groups,
            ),
            text: "Grupos",
          ),
          Tab(
            icon: _buildShowcaseIcon(
              key: _profileTabKey,
              title: "Perfil",
              description: "Suas estatísticas, medalhas e histórico de desafios.",
              icon: Icons.person,
            ),
            text: "Perfil",
          ),
        ];

        return Scaffold(
          body: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: pages,
          ),
          bottomNavigationBar: Material(
            color: AppColors.branco,
            child: TabBar(
              controller: _tabController,
              tabs: tabs,
              labelColor: AppColors.borderCinza,
              indicatorColor: AppColors.borderCinza,
            ),
          ),
        );
      },
    );
  }

  Widget _buildShowcaseIcon({
    required GlobalKey key,
    required String title,
    required String description,
    required IconData icon,
  }) {
    // Envolvemos o ícone em um Container maior para aumentar a área de destaque
    final child = Container(
      padding: const EdgeInsets.all(8),   // espaço extra ao redor do ícone
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Cor de fundo levemente transparente para manter a visibilidade
        color: AppColors.branco.withOpacity(0.15),
      ),
      child: Icon(icon, size: 30, color: AppColors.borderCinza),
    );

    return Showcase(
      key: key,
      title: title,
      description: description,
      child: child,
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
    );
  }
}

class _TutorialStep {
  final int tabIndex;
  final List<GlobalKey> keys;
  _TutorialStep({required this.tabIndex, required this.keys});
}