import 'package:flutter/material.dart';
import 'package:naturats/components/group/group_details_header.dart';
import 'package:naturats/components/group/group_navigation_tabs.dart';
import 'package:naturats/components/group/group_feed_view.dart';
import 'package:naturats/components/group/group_rank_view.dart';
import 'package:naturats/components/group/new_activity_sheet.dart';
import 'package:naturats/components/group/invite_member_dialog.dart';
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
  final RankingService _rankingService = RankingService();  // ← adicionado

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
      future: _rankingService.fetchGroupRanking(widget.id),      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError)
          return Center(child: Text('Erro: ${snapshot.error}'));
        return GroupRankView(ranking: snapshot.data ?? []);
      },
    );
  }
}