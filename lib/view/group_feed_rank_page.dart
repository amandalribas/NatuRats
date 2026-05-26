import 'package:firebase_auth/firebase_auth.dart';          // ← NOVO
import 'package:flutter/material.dart';
import 'package:naturats/components/group/group_details_header.dart';
import 'package:naturats/components/group/group_navigation_tabs.dart';
import 'package:naturats/components/group/group_feed_view.dart';
import 'package:naturats/components/group/group_rank_view.dart';
import 'package:naturats/components/group/new_activity_sheet.dart';
import 'package:naturats/components/group/invite_member_dialog.dart';
import 'package:naturats/repository/group_repository.dart'; 
import 'package:naturats/service/group_feed_service.dart';
import 'package:naturats/service/ranking_service.dart';

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

  Future<void> _leaveGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(Icons.exit_to_app, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 8),
            const Text('Sair do grupo', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(ctx).size.width * 0.8,
          child: const Text(
            'Tem certeza de que deseja sair deste grupo?\nSuas atividades continuarão visíveis.',
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;
    if (email == null) return;

    try {
      await _groupRepo.removeMember(widget.id, email);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Você saiu do grupo.'),
            backgroundColor: Colors.grey.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erro ao sair do grupo. Tente novamente.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
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
            onInvite: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => InviteMemberDialog(groupId: widget.id),
              );
            },
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