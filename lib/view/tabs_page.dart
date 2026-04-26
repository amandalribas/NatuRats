import 'package:flutter/material.dart';
import 'package:naturats/theme/app_colors.dart';
import 'home_page.dart';
import 'package:naturats/view/challenge_page.dart';
import 'package:naturats/view/groups_page.dart';
import 'package:naturats/view/profile_page.dart';

class TabsPage extends StatelessWidget {
  const TabsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomePage(),
      const ChallengeScreen(),
      const GroupPage(),
      const ProfilePage(),
    ].whereType<Widget>().toList();

    final tabs = [
      const Tab(
        icon: Icon(Icons.home_filled, size: 30),
        text: "Início",
      ),
      const Tab(
        icon: Icon(Icons.workspace_premium, size: 30),
        text: "Desafios"
      ),
      const Tab(
        icon: Icon(Icons.groups, size: 30),
        text: "Grupos",
      ),
      const Tab(
        icon: Icon(Icons.person, size: 30),
        text: "Perfil"
      ),
    ].whereType<Tab>().toList();

    return DefaultTabController(
      initialIndex: 0,
      length: pages.length,
      child: Scaffold(
        body: TabBarView(children: pages),
        bottomNavigationBar: Material(
          color: AppColors.branco,
          child: TabBar(
            tabs: tabs,
            labelColor: AppColors.borderCinza,
            indicatorColor: AppColors.borderCinza,
          ),
        ),
      ),
    );
  }
}