// lib/view/finish_challenge_dialog.dart
import 'dart:convert'; // para base64Decode
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:naturats/components/challenge/challenge_impact_desc.dart';
import 'package:naturats/model/challenge.dart';
import 'package:naturats/model/group_model.dart';
import 'package:naturats/repository/group_repository.dart';
import 'package:naturats/service/group_feed_service.dart';

class FinishChallengeDialog extends StatefulWidget {
  final int points;
  final Challenge challenge;

  const FinishChallengeDialog({
    super.key,
    required this.points,
    required this.challenge,
  });

  @override
  State<FinishChallengeDialog> createState() => _FinishChallengeDialogState();
}

class _FinishChallengeDialogState extends State<FinishChallengeDialog> {
  final GroupRepository _groupRepo = GroupRepository();
  final GroupFeedService _feedService = GroupFeedService();

  List<GroupModel> _groups = [];
  bool _loadingGroups = false;
  Set<GroupModel> _selectedGroups = {};
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() => _loadingGroups = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final email = user.email ?? '';
      try {
        _groups = await _groupRepo.fetchVisibleGroups(email);
      } catch (e) {
        debugPrint('Erro ao carregar grupos: $e');
      }
    }
    setState(() => _loadingGroups = false);
  }

  Future<void> _shareToGroups() async {
  if (_selectedGroups.isEmpty) return;

  setState(() => _isSharing = true);
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  int successCount = 0;
  for (final group in _selectedGroups) {
    try {
      await _feedService.createActivity(
        groupId: group.id,
        title: 'Desafio Concluído: ${widget.challenge.title}',
        description: '${user.displayName ?? 'Alguém'} completou o desafio "${widget.challenge.title}" e ganhou ${widget.points} pontos!',
        missionType: widget.challenge.type.label,
        imageBase64: null,
      );
      successCount++;
    } catch (e) {
      debugPrint('Erro ao compartilhar no grupo ${group.name}: $e');
    }
  }

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          successCount == _selectedGroups.length
              ? 'Compartilhado em todos os grupos!'
              : 'Compartilhado em $successCount grupo(s) (falhou em ${_selectedGroups.length - successCount})',
        ),
      ),
    );
  }

  setState(() => _isSharing = false);
}

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícone de sucesso
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 52),
            ),
            const SizedBox(height: 24),
            const Text(
              "Muito bem!",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.black),
            ),
            const SizedBox(height: 10),
            Text(
              "Ação registrada com sucesso.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 28),

            // Pontos e impacto
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF4FAF4),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.eco, color: Colors.green.shade700, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        "+${widget.points} pontos",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ChallengeImpact(map: widget.challenge.statistics),
                ],
              ),
            ),
            const SizedBox(height: 26),

            // Botão "Continuar"
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text(
                  "Continuar",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Botão "Compartilhar com grupo"
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () => _showGroupPicker(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.green.shade700),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: Text(
                  "Compartilhar com grupo",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGroupPicker(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        if (_loadingGroups) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_groups.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: const Text(
              'Você não participa de nenhum grupo ainda.',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        final localSelected = Set<GroupModel>.from(_selectedGroups);

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Barra de arraste
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Compartilhar com',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _groups.length,
                      itemBuilder: (_, index) {
                        final group = _groups[index];
                        final isSelected = localSelected.contains(group);

                        Widget groupImage;
                        if (group.image.isNotEmpty) {
                          try {
                            final bytes = base64Decode(group.image);
                            groupImage = ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                bytes,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                              ),
                            );
                          } catch (_) {
                            groupImage = _defaultGroupAvatar();
                          }
                        } else {
                          groupImage = _defaultGroupAvatar();
                        }

                        return Card(
                          elevation: 1,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              setModalState(() {
                                if (isSelected) {
                                  localSelected.remove(group);
                                } else {
                                  localSelected.add(group);
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  groupImage,
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          group.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${group.totalPeople} membros',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                                    color: isSelected ? Colors.green : Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Botão de confirmar compartilhamento
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          setState(() {
                            _selectedGroups = localSelected;
                          });
                          if (_selectedGroups.isNotEmpty) {
                            _shareToGroups();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Compartilhar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _defaultGroupAvatar() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.group, color: Colors.green, size: 30),
    );
  }
}