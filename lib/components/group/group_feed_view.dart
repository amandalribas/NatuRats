import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:naturats/model/group_activity.dart';
import 'package:naturats/repository/group_repository.dart'; // ← NOVO
import 'package:naturats/service/group_feed_service.dart'; // ← NOVO
import 'package:naturats/theme/app_colors.dart';
import 'package:naturats/view/activity_detail_page.dart';
import 'package:naturats/view/report_page.dart';

Uint8List _decodeBase64Isolate(String data) {
  final comma = data.indexOf(',');
  final payload = comma != -1 ? data.substring(comma + 1) : data;
  return base64Decode(payload);
}

class GroupFeedView extends StatefulWidget {
  final String groupId;
  const GroupFeedView({super.key, required this.groupId});

  @override
  State<GroupFeedView> createState() => _GroupFeedViewState();
}

class _GroupFeedViewState extends State<GroupFeedView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Map<String, Uint8List> _imageCache = {};

  final GroupRepository _groupRepo = GroupRepository(); // ← NOVO
  final GroupFeedService _feedService = GroupFeedService(); // ← NOVO

  bool _isAdmin = false; // ← NOVO
  bool _adminChecked = false; // ← NOVO

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final user = _auth.currentUser;
    if (user != null) {
      final isAdmin = await _groupRepo.isUserAdmin(widget.groupId, user.uid);
      if (mounted) {
        setState(() {
          _isAdmin = isAdmin;
          _adminChecked = true;
        });
      }
    } else {
      if (mounted) setState(() => _adminChecked = true);
    }
  }

  Stream<List<GroupActivity>> _activitiesStream() {
    return _firestore
        .collection('groups')
        .doc(widget.groupId)
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inHours < 1) return '${diff.inMinutes} min';
    if (diff.inDays < 1)
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    return '${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  Color _missionColor(String type) {
    switch (type) {
      case 'biodiversidade':
        return Colors.green;
      case 'água':
        return Colors.blue;
      case 'energia':
        return Colors.orange;
      case 'resíduo':
        return Colors.brown;
      case 'mobilidade':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                final hasPhoto = decodedImage != null;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ActivityDetailPage(
                            activity: activity,
                            groupId: widget.groupId,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor:
                                    isMe ? Colors.green : Colors.grey,
                                backgroundImage: hasPhoto
                                    ? MemoryImage(decodedImage!)
                                    : null,
                                child: !hasPhoto
                                    ? Text(
                                        activity.senderName.isNotEmpty
                                            ? activity.senderName[0]
                                                .toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      )
                                    : null,
                              ),
                              if (hasPhoto)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 1.5),
                                    ),
                                    child: const Icon(Icons.camera_alt,
                                        size: 10, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            activity.senderName,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          activity.createdAt != null
                                              ? _formatTime(activity.createdAt!)
                                              : '',
                                          style: const TextStyle(
                                              fontSize: 12, color: AppColors.bgCinza),
                                        ),
                                      ],
                                    ),
                                    if (!isMe || _isAdmin)
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: () => _showOptionsSheet(activity),
                                          child: const Icon(Icons.more_vert, size: 20),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  activity.title,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    if (activity.missionType ==
                                        'challenge_share')
                                      Chip(
                                        backgroundColor:
                                            Colors.grey.shade200,
                                        label: const Text('Desafio',
                                            style: TextStyle(
                                                fontWeight:
                                                    FontWeight.bold)),
                                      ),
                                    Chip(
                                      backgroundColor: _missionColor(
                                              activity.missionType)
                                          .withOpacity(0.2),
                                      label: Text(
                                        activity.missionType,
                                        style: TextStyle(
                                          color: _missionColor(
                                              activity.missionType),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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

  // ────────── BOTTOM SHEET COM OPÇÕES ──────────
  void _showOptionsSheet(GroupActivity activity) {
    final isMe = (activity.senderId == _auth.currentUser?.uid);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // Denunciar (só aparece para posts de outros)
            if (!isMe)
              ListTile(
                leading: const Icon(Icons.flag_outlined,
                    color: AppColors.vermelho),
                title: const Text('Denunciar post'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReportPage(
                        groupId: widget.groupId,
                        targetId: activity.id,
                        targetType: 'post',
                        targetUserId: activity.senderId,
                        targetName: activity.senderName,
                      ),
                    ),
                  );
                },
              ),
            // Apagar (só para admins)
            if (_isAdmin)
              ListTile(
                leading:
                    const Icon(Icons.delete, color: AppColors.vermelho),
                title: const Text('Apagar',
                    style: TextStyle(color: AppColors.vermelho)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      title: const Text('Apagar post'),
                      content: const Text(
                          'Tem certeza que deseja apagar este post permanentemente?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.vermelho,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Apagar',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    try {
                      await _feedService.deleteActivity(
                        groupId: widget.groupId,
                        activityId: activity.id,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Post apagado.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Erro ao apagar.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}