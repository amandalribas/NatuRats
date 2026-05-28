import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:naturats/repository/group_repository.dart';
import 'package:naturats/theme/app_colors.dart';

class ManageMembersPage extends StatefulWidget {
  final String groupId;

  const ManageMembersPage({super.key, required this.groupId});

  @override
  State<ManageMembersPage> createState() => _ManageMembersPageState();
}

class _ManageMembersPageState extends State<ManageMembersPage> {
  final GroupRepository _groupRepo = GroupRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, String>> _members = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _loading = true);
    try {
      final memberDoc = await _firestore
          .collection('groups')
          .doc(widget.groupId)
          .collection('members')
          .doc('members')
          .get();

      List<String> emails = [];
      if (memberDoc.exists) {
        emails = List<String>.from(memberDoc.data()?['emails'] ?? []);
      }

      List<Map<String, String>> members = [];
      for (final email in emails) {

        String name = email; 
        try {
          final userQuery = await _firestore
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();
          if (userQuery.docs.isNotEmpty) {
            final userData = userQuery.docs.first.data();
            name = userData['name'] ?? email;
          }
        } catch (_) {}
        members.add({'email': email, 'name': name});
      }

      if (mounted) {
        setState(() {
          _members = members;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao carregar membros.')),
        );
      }
    }
  }

  Future<void> _removeMember(String email, int index) async {

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remover membro',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Tem certeza de que deseja remover $email do grupo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.vermelho,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _groupRepo.removeMember(widget.groupId, email);
      setState(() {
        _members.removeAt(index);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$email foi removido.'),
            backgroundColor: AppColors.vermelho,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao remover membro.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar membros'),
        backgroundColor: AppColors.bgVerde,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _members.isEmpty
              ? const Center(
                  child: Text('Nenhum membro.',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _members.length,
                  itemBuilder: (context, index) {
                    final member = _members[index];
                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.bgVerde.withOpacity(0.2),
                          child: Text(
                            member['name']?.isNotEmpty == true
                                ? member['name']![0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                color: AppColors.bgVerde,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          member['name'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(member['email'] ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle,
                              color: AppColors.vermelho),
                          onPressed: () => _removeMember(
                              member['email']!, index),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
} 