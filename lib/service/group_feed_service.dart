import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:naturats/model/group_activity.dart';

class GroupFeedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Map<String, Uint8List> _imageCache = {};

  Stream<List<GroupActivity>> activitiesStream(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
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

  Future<void> createActivity({
    required String groupId,
    required String title,
    required String description,
    required String missionType,
    String? imageBase64,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    final senderName = user.displayName ?? user.email ?? 'Você';

    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('activities')
        .add({
      'senderName': senderName,
      'senderId': user.uid,
      'title': title,
      'description': description,
      'missionType': missionType,
      'photoBase64': imageBase64 != null && imageBase64.isNotEmpty ? imageBase64 : null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Decodifica imagem com cache e isolate
  Future<Uint8List?> decodeImage(String? base64) async {
    if (base64 == null || base64.isEmpty) return null;
    if (_imageCache.containsKey(base64)) return _imageCache[base64];
    try {
      final bytes = await compute(_decodeIsolate, base64);
      _imageCache[base64] = bytes;
      return bytes;
    } catch (_) {
      return null;
    }
  }

  static Uint8List _decodeIsolate(String data) {
    final comma = data.indexOf(',');
    final payload = comma != -1 ? data.substring(comma + 1) : data;
    return base64Decode(payload);
  }
}