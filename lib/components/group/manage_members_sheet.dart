import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:naturats/repository/group_repository.dart';

class ManageMembersSheet extends StatefulWidget {
  final String groupId;

  const ManageMembersSheet({super.key, required this.groupId});

  @override
  State<ManageMembersSheet> createState() => _ManageMembersSheetState();
}

class _ManageMembersSheetState extends State<ManageMembersSheet> {
  final GroupRepository _groupRepo = GroupRepository();
  List<Map<String, dynamic>> _members = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final members = await _groupRepo.getGroupMembers(widget.groupId);
    setState(() {
      _members = members;
      _loading = false;
    });
  }

  Future<void> _removeMember(String email) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Expulsar membro'),
        content: Text('Tem certeza que deseja expulsar $email?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Expulsar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await _groupRepo.removeMember(widget.groupId, email);
    await _loadMembers(); // recarrega a lista
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$email foi expulso do grupo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Membros do grupo',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _members.isEmpty
                    ? const Text('Nenhum membro.')
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _members.length,
                        itemBuilder: (_, index) {
                          final member = _members[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: member['photoUrl'] != null
                                  ? NetworkImage(member['photoUrl'])
                                  : null,
                              child: member['photoUrl'] == null
                                  ? Text((member['name'] as String)[0].toUpperCase())
                                  : null,
                            ),
                            title: Text(member['name'] as String),
                            subtitle: Text(member['email'] as String),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: Colors.red),
                              onPressed: () => _removeMember(member['email'] as String),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}