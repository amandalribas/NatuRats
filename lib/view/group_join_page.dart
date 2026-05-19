import 'package:flutter/material.dart';
import 'package:naturats/model/group_model.dart';
import 'package:naturats/controller/group_join_controller.dart';
import 'package:naturats/theme/app_colors.dart';
import 'package:naturats/view/group_feed_rank_page.dart';
import 'package:naturats/utils/base64_image.dart';

class GroupJoinPage extends StatefulWidget {
  final GroupModel group;

  const GroupJoinPage({super.key, required this.group});

  @override
  State<GroupJoinPage> createState() => _GroupJoinPageState();
}

class _GroupJoinPageState extends State<GroupJoinPage> {
  late final GroupJoinController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GroupJoinController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _joinGroup() async {
    final userEmail = await _controller.join(widget.group);

    if (!mounted) {
      return;
    }

    if (userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faça login com um e-mail para entrar no grupo.')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GroupFeedRankPage(
          id: widget.group.id,
          name: widget.group.name,
          description: widget.group.description,
          totalPeople: widget.group.totalPeople,
          totalPoints: widget.group.totalPoints,
          imageUrl: widget.group.image,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageBytes = decodeBase64Image(widget.group.image);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.branco,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: imageBytes != null
                                ? Image.memory(
                                    imageBytes,
                                    height: 220,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    height: 220,
                                    width: double.infinity,
                                    color: AppColors.borderCinza.withOpacity(0.15),
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.groups_outlined, size: 72),
                                  ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            widget.group.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const SizedBox(height: 16),
                          Text(
                            widget.group.description,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _controller.isJoining ? null : _joinGroup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.bgVerde,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _controller.isJoining
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Entrar no grupo',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}