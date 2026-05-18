import 'package:flutter/material.dart';
import 'package:naturats/controller/invitation_controller.dart';
import 'package:naturats/model/invitation.dart';
import 'package:naturats/theme/app_colors.dart';

class GroupHeader extends StatefulWidget {
  const GroupHeader({super.key});

  @override
  State<GroupHeader> createState() => _GroupHeaderState();
}

class _GroupHeaderState extends State<GroupHeader> {
  final InvitationController _invitationController = InvitationController();

  @override
  void initState() {
    super.initState();
    _invitationController.loadInvitations();
  }

  void _showInvitationsPopup(BuildContext context) async {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final Offset offset =
        button.localToGlobal(Offset.zero, ancestor: overlay);

    final position = RelativeRect.fromLTRB(
      offset.dx + button.size.width - 20,
      offset.dy + button.size.height,
      overlay.size.width - offset.dx - button.size.width + 20,
      0,
    );

    await showMenu<void>(
      context: context,
      position: position,
      constraints: const BoxConstraints(
        maxWidth: 320,
        maxHeight: 400,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: _buildPopupItems(),
    );
  }

  List<PopupMenuEntry<void>> _buildPopupItems() {
    if (_invitationController.invitations.isEmpty) {
      return [
        const PopupMenuItem<void>(
          enabled: false,
          child: Text(
            'Nenhum convite pendente',
            style: TextStyle(color: AppColors.textCinza),
          ),
        ),
      ];
    }

    return _invitationController.invitations.map((inv) {
      return PopupMenuItem<void>(
        enabled: false,
        child: _InvitationPopupItem(
          invitation: inv,
          invitationController: _invitationController,
          onAction: () {
            Navigator.pop(context);
            setState(() {});
          },
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.18,
      width: double.infinity,
      decoration: BoxDecoration(color: AppColors.bgVerde),

      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                
                children: [
                  Text(
                    "Grupos",
                    style: TextStyle(
                      color: AppColors.branco,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                  ),
                  Text(
                    "Conecte-se com outros usuários.",
                    style: TextStyle(
                      color: AppColors.branco, fontSize: 16
                      ),
                  ),
                ],
              ),
            ),

            // Ícone de notificações com badge
            ListenableBuilder(
              listenable: _invitationController,
              builder: (context, _) {
                return Stack(
                  children: [
                    Builder(
                      builder: (buttonContext) {
                        return IconButton(
                          onPressed: () => _showInvitationsPopup(buttonContext),
                          icon: const Icon(
                            Icons.notifications,
                            color: AppColors.branco,
                            size: 28,
                          ),
                        );
                      },
                    ),
                    if (_invitationController.pendingCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            '${_invitationController.pendingCount}',
                            style: const TextStyle(
                              color: AppColors.branco,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget individual de convite dentro do popup
class _InvitationPopupItem extends StatefulWidget {
  final Invitation invitation;
  final InvitationController invitationController;
  final VoidCallback onAction;

  const _InvitationPopupItem({
    required this.invitation,
    required this.invitationController,
    required this.onAction,
  });

  @override
  State<_InvitationPopupItem> createState() => _InvitationPopupItemState();
}

class _InvitationPopupItemState extends State<_InvitationPopupItem> {
  String _groupName = '...';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadGroupName();
  }

  Future<void> _loadGroupName() async {
    final name = await widget.invitationController.getGroupName(widget.invitation.group);
    if (mounted) {
      setState(() {
        _groupName = name.isNotEmpty ? name : widget.invitation.group;
      });
    }
  }

  String _formatDeadline(DateTime deadline) {
    return '${deadline.day.toString().padLeft(2, '0')}/${deadline.month.toString().padLeft(2, '0')}/${deadline.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _groupName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'De: ${widget.invitation.sender}',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textCinza,
          ),
        ),
        Text(
          'Até: ${_formatDeadline(widget.invitation.deadline)}',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textCinza,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _isProcessing
                  ? null
                  : () async {
                      setState(() => _isProcessing = true);
                      await widget.invitationController
                          .declineInvitation(widget.invitation);
                      widget.onAction();
                    },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.vermelho,
              ),
              child: const Text('Recusar', style: TextStyle(fontSize: 13)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isProcessing
                  ? null
                  : () async {
                      setState(() => _isProcessing = true);
                      await widget.invitationController
                          .acceptInvitation(widget.invitation);
                      widget.onAction();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bgVerde,
                foregroundColor: AppColors.branco,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Aceitar', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
        const Divider(height: 1),
      ],
    );
  }
}
