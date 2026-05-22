import 'package:flutter/material.dart';

class GroupRankView extends StatelessWidget {
  final List<Map<String, dynamic>> ranking;
  const GroupRankView({super.key, required this.ranking});

  static Color _podiumColor(int place) {
    switch (place) {
      case 1: return Colors.amber;
      case 2: return Colors.grey.shade400;
      case 3: return const Color.fromARGB(255, 148, 99, 79);
      default: return Colors.grey;
    }
  }

  static String _formatPoints(int points) => '$points pts';

  @override
  Widget build(BuildContext context) {
    if (ranking.isEmpty) {
      return const Center(child: Text('Nenhum membro no grupo.'));
    }
    final top3 = ranking.take(3).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPodium(top3),
          const SizedBox(height: 24),
          _buildFullRanking(ranking),
        ],
      ),
    );
  }

  Widget _buildPodium(List<Map<String, dynamic>> top3) {
    if (top3.isEmpty) return const SizedBox.shrink();

    final positions = <int, Map<String, dynamic>>{};
    for (int i = 0; i < top3.length; i++) {
      positions[i + 1] = top3[i];
    }

    const double goldH = 160, silverH = 120, bronzeH = 80;

    return Column(
      children: [
        const Text('Ranking do Grupo',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (top3.length >= 2)
                _podiumBar(positions[2]!, silverH, _podiumColor(2), '2º'),
              const SizedBox(width: 12),
              _podiumBar(positions[1]!, goldH, _podiumColor(1), '1º'),
              const SizedBox(width: 12),
              if (top3.length >= 3)
                _podiumBar(positions[3]!, bronzeH, _podiumColor(3), '3º'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _podiumBar(
      Map<String, dynamic> user, double height, Color color, String placement) {
    final photoUrl = user['photoUrl'] as String?;
    return SizedBox(
      width: 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withOpacity(0.3),
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
            child: photoUrl == null
                ? Text(
                    (user['name'] as String).isNotEmpty
                        ? (user['name'] as String)[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  )
                : null,
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(placement,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 4),
          Text(user['name'] as String,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis),
          Text(_formatPoints(user['points'] as int),
              style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildFullRanking(List<Map<String, dynamic>> allMembers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Classificação',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: allMembers.length,
          itemBuilder: (context, index) {
            final user = allMembers[index];
            final placement = index + 1;
            return Card(
              elevation: 1,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      user['photoUrl'] != null ? NetworkImage(user['photoUrl']) : null,
                  child: user['photoUrl'] == null
                      ? Text((user['name'] as String)[0].toUpperCase())
                      : null,
                ),
                title: Text('$placementº ${user['name']}'),
                trailing: Text(_formatPoints(user['points'] as int),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            );
          },
        ),
      ],
    );
  }
}