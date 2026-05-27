import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:naturats/model/group_activity.dart';
import 'package:naturats/view/activity_detail_page.dart';
import 'package:naturats/view/report_post_page.dart';

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
    if (diff.inDays < 1) return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
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

  void _showReportBottomSheet(GroupActivity activity) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: Colors.red),
                title: const Text('Denunciar post'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReportPostPage(
                        groupId: widget.groupId,
                        activity: activity,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
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
                          // Avatar circular com a foto da atividade (se houver) + ícone de câmera
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: isMe ? Colors.green : Colors.grey,
                                backgroundImage: hasPhoto
                                    ? MemoryImage(decodedImage!)
                                    : null,
                                child: !hasPhoto
                                    ? Text(
                                        activity.senderName.isNotEmpty
                                            ? activity.senderName[0].toUpperCase()
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
                          // Texto ao lado
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Nome do autor, data e menu
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        activity.senderName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                    ),
                                    Text(
                                      activity.createdAt != null
                                          ? _formatTime(activity.createdAt!)
                                          : '',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    if (!isMe)
                                      IconButton(
                                        icon: const Icon(Icons.more_vert, size: 20),
                                        onPressed: () =>
                                            _showReportBottomSheet(activity),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        tooltip: 'Opções',
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                // Título da atividade
                                Text(
                                  activity.title,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                // Chips (tipo de missão e opcional "Desafio")
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    if (activity.missionType == 'challenge_share')
                                      Chip(
                                        backgroundColor: Colors.grey.shade200,
                                        label: const Text('Desafio',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
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
}