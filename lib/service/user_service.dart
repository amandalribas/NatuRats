import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:naturats/model/user.dart';

class UserService {
  static String collection = "users";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> create(User user) async {
    try {
      await _firestore
          .collection(collection)
          .doc(user.id)
          .set(user.toMap());
    } catch (e) {
      debugPrint("Error on create user on firestore: $e.");
      rethrow;
    }
  }

  Future<User?> get(String uid) async {
    try {
      final doc = await _firestore
          .doc("$collection/$uid")
          .get();

      if (!doc.exists) {
        return null;
      }

      return User.fromMap(uid, doc.data()!);
    } catch (e) {
      debugPrint("Error on get user $uid from firestore: $e.");
      return null;
    }
  }

  Future<void> update(User user) async {
    try {
      await _firestore
          .collection(collection)
          .doc(user.id)
          .update(user.toMap());
    } catch (e) {
      debugPrint("Error updating user: $e");
      rethrow;
    }
  }

  Future<void> addFcmToken(String userId, String token) async {
    try {
      await _firestore
          .collection(collection)
          .doc(userId)
          .set({
        'fcm_tokens': FieldValue.arrayUnion([token]),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error updating FCM token: $e");
      rethrow;
    }
  }

  Future<void> removeFcmToken(String userId, String token) async {
    try {
      await _firestore
          .collection(collection)
          .doc(userId)
          .set({
        'fcm_tokens': FieldValue.arrayRemove([token]),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error removing FCM token: $e");
      rethrow;
    }
  }
  
}
