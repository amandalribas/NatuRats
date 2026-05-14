// lib/screens/activity_detail_page.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:naturats/model/group_activity.dart';

class ChatMessage {
  final String senderName;
  final String senderId;
  final String message;
  final DateTime? timestamp;

  ChatMessage({
    required this.senderName,
    required this.senderId,
    required this.message,
    this.timestamp,
  });
}

class ActivityDetailPage extends StatefulWidget {
  final GroupActivity activity;
  final String groupId;

  const ActivityDetailPage({
    super.key,
    required this.activity,
    required this.groupId,
  });

  @override
  State<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  final TextEditingController _messageCtrl = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();

  Stream<List<ChatMessage>> _chatStream() {
    return FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('activities')
        .doc(widget.activity.id)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final d = doc.data();
              return ChatMessage(
                senderName: d['senderName'] ?? '',
                senderId: d['senderId'] ?? '',
                message: d['message'] ?? '',
                timestamp: d['timestamp'] != null
                    ? (d['timestamp'] as Timestamp).toDate()
                    : null,
              );
            }).toList());
  }

  Future<void> _sendMessage() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty) return;
    final user = _auth.currentUser;
    if (user == null) return;
    final senderName = user.displayName ?? user.email ?? 'Usuário';

    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('activities')
        .doc(widget.activity.id)
        .collection('messages')
        .add({
      'senderName': senderName,
      'senderId': user.uid,
      'message': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageCtrl.clear();
    // Rolagem para o fim do chat
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.activity.title)),
      body: Column(
        children: [
          // Conteúdo rolável (detalhes + chat)
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Detalhes da atividade
                  if (widget.activity.photoBase64 != null &&
                      widget.activity.photoBase64!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        base64Decode(widget.activity.photoBase64!),
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    widget.activity.title,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Por: ${widget.activity.senderName}'),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      widget.activity.missionType,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(widget.activity.description),
                  const Divider(height: 32),
                  // Chat
                  const Text(
                    'Conversa',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<List<ChatMessage>>(
                    stream: _chatStream(),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      if (snap.hasError) {
                        return Center(child: Text('Erro: ${snap.error}'));
                      }
                      final msgs = snap.data ?? [];
                      if (msgs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Center(
                            child: Text(
                              'Nenhuma mensagem ainda.\nSeja o primeiro!',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: msgs.map((msg) {
                          final isMe =
                              (msg.senderId == _auth.currentUser?.uid);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: isMe
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                if (!isMe)
                                  CircleAvatar(
                                    backgroundColor: Colors.grey.shade400,
                                    radius: 14,
                                    child: Text(
                                      msg.senderName.isNotEmpty
                                          ? msg.senderName[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                if (!isMe) const SizedBox(width: 8),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isMe
                                          ? Colors.green.shade100
                                          : Colors.grey.shade200,
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(12),
                                        topRight: const Radius.circular(12),
                                        bottomLeft:
                                            Radius.circular(isMe ? 12 : 0),
                                        bottomRight:
                                            Radius.circular(isMe ? 0 : 12),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (!isMe)
                                          Text(
                                            msg.senderName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        Text(
                                          msg.message,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        if (msg.timestamp != null)
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: Text(
                                              _formatTime(msg.timestamp!),
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isMe) const SizedBox(width: 8),
                                if (isMe)
                                  CircleAvatar(
                                    backgroundColor: Colors.green,
                                    radius: 14,
                                    child: Text(
                                      msg.senderName.isNotEmpty
                                          ? msg.senderName[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Campo fixo de envio
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Enviar mensagem...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}