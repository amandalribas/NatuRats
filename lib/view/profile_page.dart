import 'package:flutter/material.dart';
import 'package:naturats/components/profile/top_stat_card.dart';
import 'package:naturats/components/profile/view_selector.dart';
import 'package:naturats/controller/profile_controller.dart';
import 'package:naturats/theme/app_colors.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => ProfileController(context),
        child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

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
            backgroundColor: const Color(0xFFF4F6F9),
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
                          ),
                          const SizedBox(width: 15),
                          Text(
                            "${controller.fullName}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                                // TODO
                            }, 
                            icon: const Icon(
                              Icons.settings,
                              color: AppColors.branco,
                              size: 25,
                            )
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 55),
                        child: Text(
                          'Nível ${controller.getUserLevel()} • ${controller.getUserPoints()} pontos',
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
                            child: TopStatCard(
                              title: 'Medalhas',
                              value: '${controller.getTotalMedals()}',
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                              backgroundColor: isSelected ? AppColors.buttomVerde : Colors.transparent,
                              side: BorderSide(
                                color: isSelected ? AppColors.buttomVerde : Colors.grey.shade400,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                            ),
                            child: Text(
                              _tabs[index],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                ViewSelector(selectedIndex: _selectedIndex),
              ],
            ),
          );
        }
    );
  }
}


