import 'package:cloud_firestore/cloud_firestore.dart';

class RankingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchGroupRanking(String groupId) async {
    // obtém os emails dos membros
    final memberDoc = await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .doc('members')
        .get();

    if (!memberDoc.exists) return [];

    final List<dynamic> emails = memberDoc.data()?['emails'] ?? [];
    if (emails.isEmpty) return [];

    // busca cada usuário pelo email
    List<Map<String, dynamic>> ranking = [];

    for (String email in emails) {
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        final userData = userQuery.docs.first.data();
        final level = (userData['level'] ?? 1) as int;
        final currentPoints = (userData['num_points'] ?? 0) as int;
        final totalPoints = currentPoints + 25 * level * (level - 1);

        ranking.add({
          'userId': userQuery.docs.first.id,
          'name': userData['name'] ?? 'Usuário',
          'photoUrl': userData['photoUrl'],
          'points': totalPoints,
        });
      }
    }

    // ordena decrescente por pontos
    ranking.sort((a, b) => (b['points'] as int).compareTo(a['points'] as int));
    return ranking;
  }
}