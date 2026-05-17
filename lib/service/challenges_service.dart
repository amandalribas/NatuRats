import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:naturats/model/challenge.dart';
import 'package:naturats/model/challenge_duration.dart';
import 'package:naturats/model/completed_challenges.dart';

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

  Future<List<String>> getAllUsersChallengesIDs(String userId) async {
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

  Future<List<String>> getUserActiveChallengesIDs(String userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("users")
        .doc(userId)
        .collection(collection)
        .where('status', isEqualTo: 'active')
        .get();

    List<String> activeChallengeIds = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data["challenge_id"] as String;
    }).toList();

    return activeChallengeIds;
  }


  Future<List<CompletedChallenges>> getUserCompletedChallenges(String userId) async {
    try {
      // Recupera todos os desafios concluídos do usuário.
      QuerySnapshot completedChallengesSnapshot = await _firestore
          .collection("users")
          .doc(userId)
          .collection(collection)
          .where('status', isEqualTo: 'completed')
          .get();


      QuerySnapshot allChallengesSnapshot = await _firestore
          .collection(collection)
          .get();

      List<CompletedChallenges> completedChallenges = completedChallengesSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        String challengeId = data["challenge_id"] as String;

        final challengeData = allChallengesSnapshot.docs.firstWhere((challengeDoc) => challengeDoc.id == challengeId).data() as Map<String, dynamic>;
        String title = challengeData["title"] as String;
        int points = ChallengeDuration.fromMap(challengeData["duration"] as String).points;
        DateTime completedAt = (data["completed_at"] as Timestamp).toDate();

        return CompletedChallenges(
          title: title,
          points: points,
          completedAt: completedAt,
        );
      }).toList();

      return completedChallenges;
    } catch (e) {
      debugPrint("Error on challenges service, get users completed challenges: $e");
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
        await doc.reference.update({"status": "completed", "completed_at": DateTime.now()});
      }
    } catch (e) {
      debugPrint("Error finishing challenge: $e");
      rethrow;
    }
  }
}