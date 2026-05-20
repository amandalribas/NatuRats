import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:naturats/components/group/group_feed_view.dart';
import 'package:naturats/components/group/group_details_header.dart';
import 'package:naturats/components/group/group_navigation_tabs.dart';
import 'package:naturats/components/group/gallery_image_picker.dart';
import 'package:naturats/components/group/invite_member_dialog.dart';


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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  

  void _showNewActivitySheet() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String? missionType;
    String imageBase64Local = '';

    final List<String> missionTypes = [
      'biodiversidade', 'água', 'energia', 'resíduo', 'mobilidade'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16, right: 16, top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(labelText: 'Título'),
                ),
                TextField(
                  controller: descCtrl,
                  decoration: InputDecoration(labelText: 'Descrição'),
                  maxLines: 3,
                ),
                DropdownButtonFormField<String>(
                  initialValue: missionType,
                  items: missionTypes
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (val) => setModalState(() => missionType = val),
                  decoration: InputDecoration(labelText: 'Tipo de missão'),
                ),
                const SizedBox(height: 12),
                GalleryImagePicker(
                  onImageSelected: (base64Image) {
                    setModalState(() => imageBase64Local = base64Image);
                  },
                ),
                if (imageBase64Local.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Image.memory(
                      base64Decode(imageBase64Local),
                      height: 100, width: 100, fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                    onPressed: () {
                      if (titleCtrl.text.isEmpty || missionType == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Preencha título e tipo de missão')),
                      );
                      return;
                    }
                    _createActivity(
                      title: titleCtrl.text,
                      description: descCtrl.text,
                      missionType: missionType!,
                      imageBase64: imageBase64Local,
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Publicar'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createActivity({
    required String title,
    required String description,
    required String missionType,
    String? imageBase64,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você precisa estar logado!')),
      );
      return;
    }

    final senderName = user.displayName ?? user.email ?? 'Você';

    await _firestore.collection('groups').doc(widget.id).collection('activities').add({
      'senderName': senderName,
      'senderId': user.uid,
      'title': title,
      'description': description,
      'missionType': missionType,
      'photoBase64': imageBase64 != null && imageBase64.isNotEmpty ? imageBase64 : null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _showNewActivitySheet,
              icon: const Icon(Icons.add),
              label: const Text('Nova atividade'),
            )
          : null,
      body: Column(
        children: [
          _header(),
          _navigationTabs(),
          Expanded(
            child: selectedIndex == 0 ? _buildFeed() : _buildRank(),
          ),
        ],
      ),
    );
  }

  Widget _navigationTabs() {
    return GroupNavigationTabs(
            currentIndex: selectedIndex,
            onChanged: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          );
  }

  Widget _header() {
    return GroupDetailsHeader(
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
          );
  }

  Widget _buildFeed() {
    // Delegates feed rendering to a dedicated widget so the rest of the page
    // remains interactive while the feed loads.
    return GroupFeedView(groupId: widget.id);
  }

  Widget _buildRank() {
    return const Center(child: Text("RANK DO GRUPO AQUI"));
  }
}