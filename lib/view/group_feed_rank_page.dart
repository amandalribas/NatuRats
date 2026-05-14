import 'package:flutter/material.dart';
import 'package:naturats/components/group/group_details_header.dart';
import 'package:naturats/components/group/group_navigation_tabs.dart';

class GroupFeedPage extends StatefulWidget {
  final String id;
  final String name;
  final String description;
  final int totalPeople;
  final int totalPoints;
  final String imageUrl;

  const GroupFeedPage({
    super.key,
    required this.id,
    required this.name,
    required this.description,
    required this.totalPeople,
    required this.totalPoints,
    required this.imageUrl,
  });

  @override
  State<GroupFeedPage> createState() => _GroupFeedPageState();
}

class _GroupFeedPageState extends State<GroupFeedPage> {
  int selectedIndex = 0;
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GroupDetailsHeader(
            name: widget.name,
            imageUrl: widget.imageUrl,
            people: widget.totalPeople,
            points: widget.totalPoints,
          ),

          GroupNavigationTabs(
            currentIndex: selectedIndex,
            onChanged: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),

          Expanded(
            child: selectedIndex == 0
                ? _buildFeed()
                : _buildRank(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeed() {
    return const Center(
      child: Text("FEED DO GRUPO AQUI"),
    );
  }

  Widget _buildRank() {
    return const Center(
      child: Text("RANK DO GRUPO AQUI"),
    );
  }
}