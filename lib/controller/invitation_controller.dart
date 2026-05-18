import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:naturats/model/invitation.dart';
import 'package:naturats/repository/group_repository.dart';
import 'package:naturats/service/invitation_service.dart';

class InvitationController extends ChangeNotifier {
  final InvitationService _invitationService = InvitationService();
  final GroupRepository _groupRepository = GroupRepository();

  List<Invitation> _invitations = [];
  bool isLoading = false;

  List<Invitation> get invitations => _invitations;

  int get pendingCount => _invitations.length;

  Future<void> loadInvitations() async {
    isLoading = true;
    notifyListeners();

    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    final allInvitations = await _invitationService.getByRecipient(email);

    // Filtra convites expirados e os deleta automaticamente
    final now = DateTime.now();
    final valid = <Invitation>[];

    for (final inv in allInvitations) {
      if (inv.deadline.isBefore(now)) {
        await _invitationService.delete(inv.id);
      } else {
        valid.add(inv);
      }
    }

    _invitations = valid;
    isLoading = false;
    notifyListeners();
  }

  Future<void> sendInvitation(String recipientEmail, String groupId) async {
    final senderEmail = FirebaseAuth.instance.currentUser?.email;
    if (senderEmail == null) {
      throw Exception("Usuário não autenticado.");
    }

    final exists = await _invitationService.recipientExists(recipientEmail);
    if (!exists) {
      throw Exception("Email não encontrado.");
    }

    // Verifica convite duplicado
    final existing = await _invitationService.getByRecipient(recipientEmail);
    final duplicate = existing.any(
      (inv) => inv.group == groupId && inv.sender == senderEmail,
    );
    if (duplicate) {
      throw Exception("Convite já enviado para este usuário.");
    }

    final invitation = Invitation(
      id: '',
      sender: senderEmail,
      recipient: recipientEmail,
      group: groupId,
      deadline: DateTime.now().add(const Duration(days: 7)),
    );

    await _invitationService.create(invitation);
  }

  Future<void> acceptInvitation(Invitation inv) async {
    await _groupRepository.addMemberToGroup(inv.group, inv.recipient);
    await _invitationService.delete(inv.id);

    _invitations.removeWhere((i) => i.id == inv.id);
    notifyListeners();
  }

  Future<void> declineInvitation(Invitation inv) async {
    await _invitationService.delete(inv.id);

    _invitations.removeWhere((i) => i.id == inv.id);
    notifyListeners();
  }

  /// Retorna o nome do grupo a partir do seu ID
  Future<String> getGroupName(String groupId) async {
    return _groupRepository.getGroupName(groupId);
  }
}
