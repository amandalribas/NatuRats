import 'package:flutter/material.dart';
import 'package:naturats/components/group/group_header.dart';
import 'package:naturats/components/group/group_search_bar.dart';
import 'package:naturats/components/group/group_options_sheet.dart';
import 'package:naturats/components/group/group_card.dart';
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const GroupOptionsSheet(),
    );

    if (!context.mounted || action != 'create_group') {
      return;
    }

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

      // ➕ BOTÃO FLUTUANTE
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showOptions(context),
        backgroundColor: AppColors.bgVerde,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GroupHeader(),

            // LISTA DE GRUPOS
            ListenableBuilder(
              listenable: _groupController,
              builder: (context, _) {
                if (_groupController.isLoading) {
                  return const Column(children: [
                    SizedBox(height: 30),
                    Center(child: CircularProgressIndicator())
                  ]);
                }

                return Column(
                  children: [
                    const SizedBox(height: 15),
                    GroupSearchBar(onChanged: _groupController.updateSearch),
                    const SizedBox(height: 20),
                    ..._groupController.groups
                        .map((group) => GroupCard(group: group))
                  ]
                );
              }
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
