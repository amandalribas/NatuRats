import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:naturats/repository/group_repository.dart';
import 'package:naturats/components/group/invite_member_dialog.dart';
import 'package:naturats/theme/app_colors.dart';

class GroupMembersPage extends StatefulWidget {
  final String groupId;
  const GroupMembersPage({super.key, required this.groupId});
  @override
  State<GroupMembersPage> createState() => _GroupMembersPageState();
}

class _GroupMembersPageState extends State<GroupMembersPage> {
  final GroupRepository _groupRepo = GroupRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _members = [];
  Set<String> _adminIds = {};
  bool _loading = true;
  bool _isViewerAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final user = _auth.currentUser;
    if (user != null) {
      _isViewerAdmin = await _groupRepo.isUserAdmin(widget.groupId, user.uid);
    }
    final results = await Future.wait([
      _groupRepo.getGroupAdmins(widget.groupId),
      _groupRepo.getGroupMembers(widget.groupId),
    ]);
    _adminIds = (results[0] as List<String>).toSet();
    _members = (results[1] as List<Map<String, dynamic>>)
        .map((m) => {...m, 'userId': m['userId'] ?? m['email']})
        .toList();
    _members.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    setState(() => _loading = false);
  }

  // ────────────── AÇÕES ──────────────

  void _showReportSheet(Map<String, dynamic> member) {
    String? reason;
    final descCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const Text(
                  'Denunciar usuário',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: reason,
                  items: ['Spam', 'Assédio', 'Conteúdo impróprio', 'Outro']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) => setModalState(() => reason = v),
                  decoration: const InputDecoration(labelText: 'Motivo'),
                ),
                if (reason == 'Outro')
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextField(
                      controller: descCtrl,
                      decoration: const InputDecoration(labelText: 'Descrição'),
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.vermelho,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (reason == null) return;
                    await FirebaseFirestore.instance.collection('reports').add({
                      'reporterId': _auth.currentUser!.uid,
                      'targetUserId': member['userId'],
                      'reason': reason,
                      'description': reason == 'Outro' ? descCtrl.text : null,
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Denúncia enviada.'),
                        backgroundColor: AppColors.vermelho,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  child: const Text('Enviar', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOptionsSheet(Map<String, dynamic> member) {
    final isSelf = member['userId'] == _auth.currentUser?.uid;
    final isMemberAdmin = _adminIds.contains(member['userId']);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
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
              // Denunciar (todos podem, exceto a si mesmo)
              if (!isSelf)
                ListTile(
                  leading: const Icon(Icons.flag_outlined, color: AppColors.vermelho),
                  title: const Text('Denunciar usuário'),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Funcionalidade em breve.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              // Remover (apenas admin e não a si mesmo)
              if (_isViewerAdmin && !isSelf)
                ListTile(
                  leading: const Icon(Icons.remove_circle, color: AppColors.vermelho),
                  title: const Text('Remover', style: TextStyle(color: AppColors.vermelho)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _confirmRemoveMember(member);
                  },
                ),
              // Tornar administrador (apenas admin, para quem ainda não é)
              if (_isViewerAdmin && !isSelf && !isMemberAdmin)
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings, color: AppColors.bgVerde),
                  title: const Text('Tornar administrador'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _promoteToAdmin(member);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmRemoveMember(Map<String, dynamic> member) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remover membro'),
        content: Text('Tem certeza que deseja remover ${member['name']} do grupo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.vermelho,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    await _groupRepo.removeMember(widget.groupId, member['email']);
    if (_adminIds.contains(member['userId'])) {
      await _groupRepo.removeAdmin(widget.groupId, member['userId']);
    }
    _loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${member['name']} foi removido.'),
        backgroundColor: AppColors.vermelho,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _promoteToAdmin(Map<String, dynamic> member) async {
    await _groupRepo.addAdmin(widget.groupId, member['userId']);
    _loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${member['name']} agora é administrador.'),
        backgroundColor: AppColors.bgVerde,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Membros do grupo'),
        backgroundColor: AppColors.bgVerde,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Convidar membro',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => InviteMemberDialog(groupId: widget.groupId),
              ).then((_) => _loadData());
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _members.isEmpty
              ? const Center(child: Text('Nenhum membro.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _members.length,
                  itemBuilder: (context, index) {
                    final member = _members[index];
                    final isMemberAdmin = _adminIds.contains(member['userId']);
                    final isSelf = member['userId'] == _auth.currentUser?.uid;

                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: member['photoUrl'] != null && member['photoUrl'].toString().isNotEmpty
                              ? NetworkImage(member['photoUrl'])
                              : null,
                          child: member['photoUrl'] == null || member['photoUrl'].toString().isEmpty
                              ? Text(
                                  (member['name'] as String).isNotEmpty
                                      ? member['name'][0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        title: Row(
                          children: [
                            Flexible(
                              child: Text(
                                member['name'],
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            if (isMemberAdmin) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.bgVerde.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Administrador',
                                  style: TextStyle(
                                    color: AppColors.bgVerde,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        // Só mostra os três pontinhos se NÃO for o próprio usuário
                        trailing: isSelf
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () => _showOptionsSheet(member),
                              ),
                      ),
                    );
                  },
                ),
    );
  }
}