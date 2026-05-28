import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:naturats/model/group_model.dart';

class GroupRepository {
  Future<bool> isUserMember(String groupId, String email) async {
    final firestore = FirebaseFirestore.instance;
    final memberDoc = await firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .doc('members')
        .get();

    if (!memberDoc.exists) {
      return false;
    }

    final emails = memberDoc.data()?['emails'] as List<dynamic>? ?? [];
    return emails.contains(email);
  }

  Future<List<GroupModel>> fetchGroups() async {
    final firestore = FirebaseFirestore.instance;
    final querySnapshot = await firestore.collection('groups').get();

    return Future.wait(querySnapshot.docs.map((doc) async {
      final infoSnapshot = await doc.reference.collection('info').doc('info').get();
      final info = infoSnapshot.data() ?? {};

      return GroupModel(
        id: doc.id,
        name: info['title'] ?? '',
        description: info['description'] ?? '',
        totalPeople: 0,
        totalPoints: 0, 
        image: info['banner'] ?? '',
      );
    }));
  }

  Future<void> createGroup({required String name, required String description, required String imageBase64, required bool isPublic}) async {
    final firestore = FirebaseFirestore.instance;
    final groupDoc = firestore.collection('groups').doc();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    final batch = firestore.batch();
    batch.set(groupDoc, {'public': isPublic});
    batch.set(groupDoc.collection('info').doc('info'), {
      'banner': imageBase64,
      'created_at': FieldValue.serverTimestamp(),
      'created_by': userId,
      'description': description,
      'title': name,
      'updated_at': FieldValue.serverTimestamp(),
      'updated_by': userId,
      'admins': [userId],
    });
    batch.set(groupDoc.collection('members').doc('members'), {
      'emails': [userEmail],
    });

    await batch.commit();
  }

  Future<List<GroupModel>> fetchVisibleGroups(String userEmail) async {
    final firestore = FirebaseFirestore.instance;

    // Busca grupos públicos
    final publicGroupsSnapshot = await firestore
        .collection('groups')
        .where('public', isEqualTo: true)
        .get();
    
    // Busca grupos privados onde o usuário é membro
    final allPrivateGroupsSnapshot = await firestore
        .collection('groups')
        .where('public', isEqualTo: false)
        .get();

    List<QueryDocumentSnapshot> privateGroupsSnapshot = [];
    for (var groupDoc in allPrivateGroupsSnapshot.docs) {
      final memberDoc = await groupDoc.reference
          .collection('members')
          .doc('members')
          .get();
      
      if (memberDoc.exists) {
        final emails = memberDoc.data()?['emails'] as List<dynamic>? ?? [];
        if (emails.contains(userEmail)) {
          privateGroupsSnapshot.add(groupDoc);
        }
      }
    }

    List<GroupModel> visibleGroups = [];

    for (var doc in publicGroupsSnapshot.docs) {
      final infoSnapshot = await doc.reference.collection('info').doc('info').get();
      final info = infoSnapshot.data() ?? {};
      
      // Conta número de membros
      final memberDoc = await doc.reference.collection('members').doc('members').get();
      final emails = memberDoc.data()?['emails'] as List<dynamic>? ?? [];
      final groupLength = emails.length;
      final totalPoints = await calculateGroupPoints(emails);
      
      visibleGroups.add(GroupModel(
        id: doc.id,
        name: info['title'] ?? '',
        description: info['description'] ?? '',
        totalPeople: groupLength,
        totalPoints: totalPoints,
        image: info['banner'] ?? '',
      ));
    }

    for (var doc in privateGroupsSnapshot) {
      final infoSnapshot = await doc.reference.collection('info').doc('info').get();
      final info = infoSnapshot.data() ?? {};

      // Conta número de membros
      final memberDoc = await doc.reference.collection('members').doc('members').get();
      final emails = memberDoc.data()?['emails'] as List<dynamic>? ?? [];
      final groupLength = emails.length;
      final totalPoints = await calculateGroupPoints(emails);

      visibleGroups.add(GroupModel(
        id: doc.id,
        name: info['title'] ?? '',
        description: info['description'] ?? '',
        totalPeople: groupLength,
        totalPoints: totalPoints,
        image: info['banner'] ?? '',
      ));
    }

    return visibleGroups;
  }

  Future<int> calculateGroupPoints(List<dynamic> emails) async {
    final firestore = FirebaseFirestore.instance;

    int totalPoints = 0;

    for (final email in emails) {
      final userSnapshot = await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final userData = userSnapshot.docs.first.data();

        final currentPoints = (userData['num_points'] ?? 0) as int;
        final level = (userData['level'] ?? 1) as int;

        final userTotalPoints = currentPoints + (level * (level - 1) * 25);

        totalPoints += userTotalPoints;
      }
    }

    return totalPoints;
  }

  Future<List<GroupModel>> fetchUserGroups(String userId) async {
    final firestore = FirebaseFirestore.instance;
    final querySnapshot = await firestore
        .collection('groups')
        .where('info.created_by', isEqualTo: userId) // TODO: Verificar se o usuário é membro do grupo, não apenas criador
        .get();

    return Future.wait(querySnapshot.docs.map((doc) async {
      final infoSnapshot = await doc.reference.collection('info').doc('info').get();
      final info = infoSnapshot.data() ?? {};

      return GroupModel(
        id: doc.id,
        name: info['title'] ?? '',
        description: info['description'] ?? '',
        totalPeople: 0, // TODO
        totalPoints: 0, // TODO
        image: info['banner'] ?? '',
      );
    }));
  }

  Future<void> addMemberToGroup(String groupId, String email) async {
    final firestore = FirebaseFirestore.instance;
    await firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .doc('members')
        .set({
      'emails': FieldValue.arrayUnion([email]),
    }, SetOptions(merge: true));
  }

  Future<String> getGroupName(String groupId) async {
    final firestore = FirebaseFirestore.instance;
    final infoSnapshot = await firestore
        .collection('groups')
        .doc(groupId)
        .collection('info')
        .doc('info')
        .get();

    final info = infoSnapshot.data() ?? {};
    return info['title'] ?? '';
  }

  Future<Set<String>> getUserGroupIds(String userEmail) async {
  final firestore = FirebaseFirestore.instance;
  final groupsSnapshot = await firestore
      .collection('groups')
      .get();

  final Set<String> userGroupIds = {};

  for (var groupDoc in groupsSnapshot.docs) {
    final memberDoc = await groupDoc.reference
        .collection('members')
        .doc('members')
        .get();
    if (memberDoc.exists) {
      final emails = memberDoc.data()?['emails'] as List<dynamic>? ?? [];
      if (emails.contains(userEmail)) {
        userGroupIds.add(groupDoc.id);
      }
    }
  }
  return userGroupIds;
}

  Future<List<GroupModel>> fetchMyGroups() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    final email = user.email ?? '';
    return fetchVisibleGroups(email);
  }

  Future<void> removeMember(String groupId, String email) async {
    final firestore = FirebaseFirestore.instance;
    await firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .doc('members')
        .update({
      'emails': FieldValue.arrayRemove([email]),
    });
  }

  Future<String?> getGroupCreator(String groupId) async {
  final doc = await FirebaseFirestore.instance
      .collection('groups')
      .doc(groupId)
      .collection('info')
      .doc('info')
      .get();
  if (!doc.exists) return null;
  return doc.data()?['created_by'] as String?;
}

Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
  final memberDoc = await FirebaseFirestore.instance
      .collection('groups')
      .doc(groupId)
      .collection('members')
      .doc('members')
      .get();
  if (!memberDoc.exists) return [];
  final emails = List<String>.from(memberDoc.data()?['emails'] ?? []);
  
  List<Map<String, dynamic>> members = [];
  for (final email in emails) {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (userSnapshot.docs.isNotEmpty) {
      final userData = userSnapshot.docs.first.data();
      members.add({
        'email': email,
        'name': userData['name'] ?? email,
        'photoUrl': userData['photoUrl'],
        'userId': userSnapshot.docs.first.id,   // ← ADICIONE userId AQUI
      });
    } else {
      members.add({
        'email': email,
        'name': email,
        'photoUrl': null,
        'userId': email,   // ← ADICIONE userId AQUI
      });
    }
  }
  return members;
}

// ══════════════ ADMIN ══════════════
Future<List<String>> getGroupAdmins(String groupId) async {
  final doc = await FirebaseFirestore.instance
      .collection('groups')
      .doc(groupId)
      .collection('info')
      .doc('info')
      .get();
  if (!doc.exists) return [];
  return List<String>.from(doc.data()?['admins'] ?? []);
}

Future<bool> isUserAdmin(String groupId, String userId) async {
  final admins = await getGroupAdmins(groupId);
  return admins.contains(userId);
}

Future<void> addAdmin(String groupId, String userId) async {
  await FirebaseFirestore.instance
      .collection('groups')
      .doc(groupId)
      .collection('info')
      .doc('info')
      .update({
    'admins': FieldValue.arrayUnion([userId]),
  });
}

Future<void> removeAdmin(String groupId, String userId) async {
  await FirebaseFirestore.instance
      .collection('groups')
      .doc(groupId)
      .collection('info')
      .doc('info')
      .update({
    'admins': FieldValue.arrayRemove([userId]),
  });
}

Future<bool> canLeaveGroup(String groupId, String userId) async {
  final admins = await getGroupAdmins(groupId);
  if (!admins.contains(userId)) return true;
  return admins.where((id) => id != userId).isNotEmpty;
}
}
