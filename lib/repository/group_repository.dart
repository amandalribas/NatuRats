import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:naturats/model/group_model.dart';

class GroupRepository {
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
        totalPeople: 0, // TODO
        totalPoints: 0, // TODO
        image: info['banner'] ?? '',
      );
    }));
  }

  Future<void> createGroup({required String name, required String description, required String imageBase64, required bool isPublic}) async {
    final firestore = FirebaseFirestore.instance;
    final groupDoc = firestore.collection('groups').doc();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

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
      
      visibleGroups.add(GroupModel(
        id: doc.id,
        name: info['title'] ?? '',
        description: info['description'] ?? '',
        totalPeople: groupLength,
        totalPoints: 0, // TODO
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

      visibleGroups.add(GroupModel(
        id: doc.id,
        name: info['title'] ?? '',
        description: info['description'] ?? '',
        totalPeople: groupLength,
        totalPoints: 0, // TODO
        image: info['banner'] ?? '',
      ));
    }

    return visibleGroups;
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
}
