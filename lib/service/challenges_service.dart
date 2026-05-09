import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:naturats/model/challenge.dart';

class ChallengesService {
  static String collection = "challenges";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Challenge?> get(String id) async {
    try {
      final doc = await _firestore
          .doc("$collection/$id")
          .get();

      if (!doc.exists) {
        return null;
      }

      return Challenge.fromMap(id, doc.data()!);
    } catch (e) {
      debugPrint("Error on get challenge $id from firestore: $e.");
      return null;
    }
  }

  Future<List<Challenge>> getAll() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(collection).get();

      return snapshot.docs.map((doc) {
        return Challenge.fromMap(
          doc.id,
          doc.data() as Map<String,dynamic>,
        );
      }).toList();
    } catch (e) {
      debugPrint("Error on get all challenges from firestore: $e.");
      return [];
    }
  }
}