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
