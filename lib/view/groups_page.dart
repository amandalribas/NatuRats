import 'package:flutter/material.dart';
import 'package:naturats/components/group/group_card.dart';
import 'package:naturats/components/group/group_header.dart';
import 'package:naturats/components/group/group_options_sheet.dart';
import 'package:naturats/components/group/group_search_bar.dart';
import 'package:naturats/controller/group_controller.dart';
import 'package:naturats/theme/app_colors.dart';
import 'package:naturats/view/group_form_page.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final GroupController _groupController = GroupController();

  @override
  void initState() {
    super.initState();
    _groupController.loadGroups();
  }

  Future<void> _showOptions(BuildContext context) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (_) => const GroupOptionsSheet(),
    );

    if (!context.mounted || action != 'create_group') return;

    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const GroupFormPage(),
      ),
    );

    if (created == true) {
      await _groupController.loadGroups();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.branco,

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showOptions(context),
        backgroundColor: AppColors.bgVerde,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(
          Icons.add,
          color: AppColors.bgCinza,
        ),
      ),

      body: Column(
        children: [
          const GroupHeader(),

          const SizedBox(height: 15),

          GroupSearchBar(
            onChanged: _groupController.updateSearch,
          ),

          const SizedBox(height: 12),

          // Tabs
          AnimatedBuilder(
            animation: _groupController,
            builder: (context, _) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                // Tabs
                child: Row(
                  children: [

                    // Meus grupos
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _groupController.setTab('my_groups');
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color:
                                _groupController.selectedTab == 'my_groups'
                                    ? AppColors.buttomVerde
                                    : AppColors.bgCinza,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Text(
                              'Meus grupos',
                              style: TextStyle(
                                color:
                                    _groupController.selectedTab ==
                                            'my_groups'
                                        ? AppColors.branco
                                        : AppColors.textCinza,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Geral
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _groupController.setTab('general');
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color:
                                _groupController.selectedTab == 'general'
                                    ? AppColors.buttomVerde
                                    : AppColors.bgCinza,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Text(
                              'Geral',
                              style: TextStyle(
                                color:
                                    _groupController.selectedTab ==
                                            'general'
                                        ? AppColors.branco
                                        : AppColors.textCinza,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Lista de grupos
          Expanded(
            child: AnimatedBuilder(
              animation: _groupController,
              builder: (context, _) {
                if (_groupController.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final groups = _groupController.groups;

                if (groups.isEmpty) {
                  return const Center(
                    child: Text(
                      "Nenhum grupo encontrado",
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  itemCount: groups.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return GroupCard(
                      group: groups[index],
                    );
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}