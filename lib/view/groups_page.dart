import 'package:flutter/material.dart';
import 'package:naturats/components/group/group_header.dart';
import 'package:naturats/components/group/group_search_bar.dart';
import 'package:naturats/components/group/group_options_sheet.dart';
import 'package:naturats/components/group/group_card.dart';
import 'package:naturats/controller/group_controller.dart';
import 'package:naturats/theme/app_colors.dart';

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

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const GroupOptionsSheet(),
    );
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

            const SizedBox(height: 15),

            const GroupSearchBar(),

            const SizedBox(height: 20),

            // LISTA DE GRUPOS
            ListenableBuilder(
              listenable: _groupController,
              builder: (context, _) {
                if (_groupController.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
                  children: _groupController.groups
                    .map((group) => GroupCard(group: group))
                    .toList(),
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
