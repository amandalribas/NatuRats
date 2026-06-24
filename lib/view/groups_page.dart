import 'package:flutter/material.dart';
import 'package:naturats/components/group/group_card.dart';
import 'package:naturats/components/group/group_header.dart';
import 'package:naturats/components/group/group_options_sheet.dart';
import 'package:naturats/components/group/group_search_bar.dart';
import 'package:naturats/controller/group_controller.dart';
import 'package:naturats/theme/app_colors.dart';
import 'package:naturats/view/group_form_page.dart';
import 'package:showcaseview/showcaseview.dart';

class GroupPage extends StatefulWidget {
  final GlobalKey? fabKey;
  final GlobalKey? searchKey;
  final GlobalKey? tabsKey;

  const GroupPage({super.key, this.fabKey, this.searchKey, this.tabsKey});

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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const GroupOptionsSheet(),
    );

    if (!context.mounted || action != 'create_group') return;

    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const GroupFormPage()),
    );

    if (created == true) {
      await _groupController.loadGroups(forceRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.branco,
      floatingActionButton: widget.fabKey == null
          ? FloatingActionButton(
              onPressed: () => _showOptions(context),
              backgroundColor: AppColors.bgVerde,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.add, color: AppColors.bgCinza),
            )
          : Showcase(
              key: widget.fabKey!,
              title: 'Criar ou entrar em um grupo',
              description:
                  'Toque aqui para criar um novo grupo ou entrar em um grupo existente usando um código de convite.',
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
              child: FloatingActionButton(
                onPressed: () => _showOptions(context),
                backgroundColor: AppColors.bgVerde,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.add, color: AppColors.bgCinza),
              ),
            ),
      body: Column(
        children: [
          const GroupHeader(),
          const SizedBox(height: 15),
          widget.searchKey == null
              ? GroupSearchBar(onChanged: _groupController.updateSearch)
              : Showcase(
                  key: widget.searchKey!,
                  title: 'Buscar grupos',
                  description:
                      'Use a busca para encontrar rapidamente um grupo pelo nome.',
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
                  child: GroupSearchBar(
                    onChanged: _groupController.updateSearch,
                  ),
                ),
          const SizedBox(height: 12),

          // Tabs
          AnimatedBuilder(
            animation: _groupController,
            builder: (context, _) {
              final tabsRow = Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _groupController.setTab('my_groups'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _groupController.selectedTab == 'my_groups'
                                ? AppColors.buttomVerde
                                : AppColors.bgCinza,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Text(
                              'Meus grupos',
                              style: TextStyle(
                                color:
                                    _groupController.selectedTab == 'my_groups'
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
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _groupController.setTab('general'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _groupController.selectedTab == 'general'
                                ? AppColors.buttomVerde
                                : AppColors.bgCinza,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Text(
                              'Geral',
                              style: TextStyle(
                                color:
                                    _groupController.selectedTab == 'general'
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

              return widget.tabsKey == null
                  ? tabsRow
                  : Showcase(
                      key: widget.tabsKey!,
                      title: 'Meus grupos / Geral',
                      description:
                          'Alterne aqui entre os grupos que você participa e a lista geral de todos os grupos disponíveis.',
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
                      child: tabsRow,
                    );
            },
          ),

          const SizedBox(height: 20),

          Expanded(
            child: AnimatedBuilder(
              animation: _groupController,
              builder: (context, _) {
                if (_groupController.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final groups = _groupController.groups;

                if (groups.isEmpty) {
                  return const Center(
                    child: Text('Nenhum grupo encontrado'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: groups.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return GroupCard(
                      group: groups[index],
                      // Ao voltar de qualquer página de grupo, recarrega a lista
                      onReturn: () => _groupController.refreshCurrentTab(),
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