import 'package:flutter/material.dart';
import 'package:naturats/model/report.dart';
import 'package:naturats/repository/report_repository.dart';
import 'package:naturats/repository/group_repository.dart';
import 'package:naturats/theme/app_colors.dart';

class GroupReportsPage extends StatefulWidget {
  final String groupId;


  final Future<void> Function(String activityId)? onDeletePost;

  const GroupReportsPage({
    super.key,
    required this.groupId,
    this.onDeletePost,
  });

  @override
  State<GroupReportsPage> createState() => _GroupReportsPageState();
}

class _GroupReportsPageState extends State<GroupReportsPage> {
  final ReportRepository _reportRepo = ReportRepository();
  final GroupRepository _groupRepo = GroupRepository();

  List<Report> _reports = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _loading = true);
    try {
      final reports =
          await _reportRepo.fetchPendingReportsForGroup(widget.groupId);
      if (mounted) setState(() { _reports = reports; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

 

  Future<void> _dismissReport(Report report) async {
    await _reportRepo.dismissReport(report.id!);
    if (mounted) setState(() => _reports.removeWhere((r) => r.id == report.id));
  }

  Future<void> _kickUser(Report report) async {
  
    final members = await _groupRepo.getGroupMembers(widget.groupId);
    final member = members.firstWhere(
      (m) => m['userId'] == report.targetUserId,
      orElse: () => {},
    );
    final email = member['email'] as String?;

    if (email == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível encontrar o membro.')),
        );
      }
      return;
    }

    final confirmed = await _confirmDialog(
      title: 'Expulsar membro',
      content: 'Deseja expulsar "${report.targetName}" do grupo?\n'
          'Suas atividades continuarão visíveis.',
      confirmLabel: 'Expulsar',
    );
    if (!confirmed) return;

    await _groupRepo.removeMember(widget.groupId, email);

    final userReports = _reports
        .where((r) => r.targetUserId == report.targetUserId)
        .toList();
    for (final r in userReports) {
      await _reportRepo.dismissReport(r.id!);
    }
    if (mounted) {
      setState(() => _reports
          .removeWhere((r) => r.targetUserId == report.targetUserId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${report.targetName} foi expulso do grupo.'),
          backgroundColor: AppColors.vermelho,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _deletePost(Report report) async {
    if (widget.onDeletePost == null) return;

    final confirmed = await _confirmDialog(
      title: 'Apagar post',
      content: 'Deseja apagar permanentemente este post?',
      confirmLabel: 'Apagar',
    );
    if (!confirmed) return;

    await widget.onDeletePost!(report.activityId);
    await _reportRepo.dismissReport(report.id!);
    if (mounted) {
      setState(() => _reports.removeWhere((r) => r.id == report.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Post removido.'),
          backgroundColor: AppColors.vermelho,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<bool> _confirmDialog({
    required String title,
    required String content,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
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
            child: Text(confirmLabel,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return result == true;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Denúncias'),
        backgroundColor: AppColors.bgVerde,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReports,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
              ? _buildEmpty()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  itemCount: _reports.length,
                  itemBuilder: (ctx, i) => _ReportCard(
                    report: _reports[i],
                    onDismiss: () => _dismissReport(_reports[i]),
                    onKickUser: _reports[i].targetType == 'user' ||
                            _reports[i].targetType == 'post'
                        ? () => _kickUser(_reports[i])
                        : null,
                    onDeletePost: _reports[i].targetType == 'post' &&
                            widget.onDeletePost != null
                        ? () => _deletePost(_reports[i])
                        : null,
                  ),
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Nenhuma denúncia pendente',
            style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Text(
            'O grupo está em ordem.',
            style:
                TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}


class _ReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback onDismiss;
  final VoidCallback? onKickUser;
  final VoidCallback? onDeletePost;

  const _ReportCard({
    required this.report,
    required this.onDismiss,
    this.onKickUser,
    this.onDeletePost,
  });

  @override
  Widget build(BuildContext context) {
    final isPost = report.targetType == 'post';
    final typeLabel = reportTypeLabels[report.type] ?? report.type.name;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                _TypeBadge(isPost: isPost),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    report.targetName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _formatDate(report.createdAt),
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
            const SizedBox(height: 10),


            Row(
              children: [
                Icon(Icons.flag_outlined,
                    size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(typeLabel,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500)),
              ],
            ),

            if (report.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                report.description,
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade700),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 10),

    
            Row(
              children: [
          
                TextButton(
                  onPressed: onDismiss,
                  child: Text(
                    'Ignorar',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ),
                const Spacer(),
                // Expulsar usuário
                if (onKickUser != null) ...[
                  OutlinedButton.icon(
                    onPressed: onKickUser,
                    icon: const Icon(Icons.person_remove, size: 16),
                    label: const Text('Expulsar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.vermelho,
                      side: BorderSide(color: AppColors.vermelho),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                    ),
                  ),
                ],
                // Apagar post (só aparece se for denúncia de post)
                if (onDeletePost != null) ...[
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: onDeletePost,
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Apagar post'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.vermelho,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inHours < 1) return '${diff.inMinutes}min atrás';
    if (diff.inDays < 1) return '${diff.inHours}h atrás';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
  }
}

class _TypeBadge extends StatelessWidget {
  final bool isPost;
  const _TypeBadge({required this.isPost});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPost
            ? Colors.orange.shade50
            : Colors.red.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPost ? Icons.article_outlined : Icons.person_outline,
            size: 12,
            color: isPost ? Colors.orange.shade700 : Colors.red.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            isPost ? 'Post' : 'Usuário',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isPost
                  ? Colors.orange.shade700
                  : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }
}