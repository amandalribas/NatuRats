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

  Future<void> startChallenge(String userId, String challengeId) async {
    try {
      await _firestore
          .collection("users")
          .doc(userId)
          .collection(collection)
          .add(Challenge.startChallengeToMap(challengeId));
    } catch (e) {
      debugPrint("Error on start new challenge: $e.");
      rethrow;
    }
  }

  Future<List<String>> getAllUsersChallenges(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection("users")
          .doc(userId)
          .collection(collection)
          .get();

      return snapshot.docs.map((doc) {
        final data =
        doc.data() as Map<String, dynamic>;
        return data["challenge_id"] as String;
      }).toList();
    } catch (e) {
      debugPrint("Error on challenges service, get users active challenges: $e");
      return [];
    }
  }

  Future<void> finishChallenge(String userId, String challengeId) async {
    try {
      final snapshot = await _firestore
          .collection("users")
          .doc(userId)
          .collection(collection)
          .where("challenge_id", isEqualTo: challengeId)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint("Error finishing challenge: $e");
      rethrow;
    }
  }
}