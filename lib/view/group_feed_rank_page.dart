import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:naturats/components/group/group_details_header.dart';
import 'package:naturats/components/group/group_navigation_tabs.dart';
import 'package:naturats/components/group/group_feed_view.dart';
import 'package:naturats/components/group/group_rank_view.dart';
import 'package:naturats/components/group/new_activity_sheet.dart';
import 'package:naturats/repository/group_repository.dart';
import 'package:naturats/service/group_feed_service.dart';
import 'package:naturats/service/ranking_service.dart';
import 'package:naturats/theme/app_colors.dart';
import 'package:naturats/view/group_members_page.dart';

class GroupFeedRankPage extends StatefulWidget {
  final String id;
  final String name;
  final String description;
  final int totalPeople;
  final int totalPoints;
  final String imageUrl;

  const GroupFeedRankPage({
    super.key,
    required this.id,
    required this.name,
    required this.description,
    required this.totalPeople,
    required this.totalPoints,
    required this.imageUrl,
  });

  @override
  State<GroupFeedRankPage> createState() => _GroupFeedRankPageState();
}

class _GroupFeedRankPageState extends State<GroupFeedRankPage> {
  int selectedIndex = 0;
  final GroupFeedService _service = GroupFeedService();
  final RankingService _rankingService = RankingService();
  final GroupRepository _groupRepo = GroupRepository();

  void _openNewActivitySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => NewActivitySheet(
        onCreate: ({
          required String title,
          required String description,
          required String missionType,
          String? imageBase64,
        }) {
          return _service.createActivity(
            groupId: widget.id,
            title: title,
            description: description,
            missionType: missionType,
            imageBase64: imageBase64,
          );
        },
      ),
    );
  }

  void _openMembersPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GroupMembersPage(groupId: widget.id)),
    );
  }

  Future<void> _leaveGroup() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final canLeave = await _groupRepo.canLeaveGroup(widget.id, user.uid);
    if (!canLeave) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Não é possível sair'),
            content: const Text('Você é o único administrador. Promova outro membro antes de sair.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(Icons.exit_to_app, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 8),
            const Text('Sair do grupo', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Tem certeza de que deseja sair deste grupo?\nSuas atividades continuarão visíveis.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.vermelho,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await _groupRepo.removeMember(widget.id, user.email!);
    await _groupRepo.removeAdmin(widget.id, user.uid).catchError((_) {});
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Você saiu do grupo.'),
          backgroundColor: AppColors.bgVerde,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _openNewActivitySheet,
              icon: const Icon(Icons.add),
              label: const Text('Nova atividade'),
            )
          : null,
      body: Column(
        children: [
          GroupDetailsHeader(
            name: widget.name,
            imageUrl: widget.imageUrl,
            people: widget.totalPeople,
            points: widget.totalPoints,
            onViewMembers: _openMembersPage,
            onLeave: _leaveGroup,
          ),
          GroupNavigationTabs(
            currentIndex: selectedIndex,
            onChanged: (i) => setState(() => selectedIndex = i),
          ),
          Expanded(
            child: selectedIndex == 0
                ? GroupFeedView(groupId: widget.id)
                : _buildRankingTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _rankingService.fetchGroupRanking(widget.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError)
          return Center(child: Text('Erro: ${snapshot.error}'));
        return GroupRankView(ranking: snapshot.data ?? []);
      },
    );
  }
}