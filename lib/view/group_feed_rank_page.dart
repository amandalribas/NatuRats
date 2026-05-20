import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:naturats/components/group/group_details_header.dart';
import 'package:naturats/components/group/group_navigation_tabs.dart';
import 'package:naturats/components/group/gallery_image_picker.dart';
import 'package:naturats/components/group/invite_member_dialog.dart';
import 'package:naturats/model/group_activity.dart';

import 'package:naturats/view/activity_detail_page.dart';

// ---------- PÁGINA PRINCIPAL ----------
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
  final Map<String, Uint8List> _imageCache = {};

// Decode base64 in an isolate to avoid blocking the UI thread.
Uint8List _decodeBase64Isolate(String data) {
  final comma = data.indexOf(',');
  final payload = comma != -1 ? data.substring(comma + 1) : data;
  return base64Decode(payload);
}

  Stream<List<GroupActivity>> _activitiesStream() {
    return _firestore
        .collection('groups')
        .doc(widget.id)
        .collection('activities')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return GroupActivity(
                id: doc.id,
                senderName: data['senderName'] ?? '',
                senderId: data['senderId'] ?? '',
                title: data['title'] ?? '',
                description: data['description'] ?? '',
                missionType: data['missionType'] ?? '',
                photoBase64: data['photoBase64'],
                createdAt: data['createdAt'] != null
                    ? (data['createdAt'] as Timestamp).toDate()
                    : null,
              );
            }).toList());
  }

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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inHours < 1) return '${diff.inMinutes} min';
    if (diff.inDays < 1) return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    return '${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  Color _missionColor(String type) {
    switch (type) {
      case 'biodiversidade': return Colors.green;
      case 'água': return Colors.blue;
      case 'energia': return Colors.orange;
      case 'resíduo': return Colors.brown;
      case 'mobilidade': return Colors.purple;
      default: return Colors.grey;
    }
  }

  Future<Uint8List?> _getDecodedImage(String? base64) async {
    if (base64 == null || base64.isEmpty) return null;
    if (_imageCache.containsKey(base64)) return _imageCache[base64];
    try {
      final bytes = await compute(_decodeBase64Isolate, base64);
      _imageCache[base64] = bytes;
      return bytes;
    } catch (_) {
      return null;
    }
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
    return StreamBuilder<List<GroupActivity>>(
      stream: _activitiesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }

        final activities = snapshot.data ?? [];

        if (activities.isEmpty) {
          return const Center(
            child: Text(
              'Nenhuma atividade publicada ainda.\nToque no botão + para criar a primeira!',
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            final isMe = (activity.senderId == _auth.currentUser?.uid);

            return FutureBuilder<Uint8List?>(
              future: _getDecodedImage(activity.photoBase64),
              builder: (context, snap) {
                final decodedImage = snap.data;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ActivityDetailPage(
                            activity: activity,
                            groupId: widget.id,   // ← essencial
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: isMe ? Colors.green : Colors.grey,
                                backgroundImage: decodedImage != null ? MemoryImage(decodedImage) : null,
                                child: decodedImage == null
                                    ? Text(
                                        activity.senderName.isNotEmpty
                                            ? activity.senderName[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(color: Colors.white),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  activity.senderName,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                activity.createdAt != null ? _formatTime(activity.createdAt!) : '',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            activity.title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          if (activity.description.isNotEmpty) Text(activity.description),
                          const SizedBox(height: 8),
                          Chip(
                            backgroundColor: _missionColor(activity.missionType).withOpacity(0.2),
                            label: Text(
                              activity.missionType,
                              style: TextStyle(
                                color: _missionColor(activity.missionType),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRank() {
    return const Center(child: Text("RANK DO GRUPO AQUI"));
  }
}