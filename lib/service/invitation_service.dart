import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:naturats/model/invitation.dart';

class InvitationService {
  static String collection = "invitations";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> create(Invitation invitation) async {
    try {
      await _firestore
          .collection(collection)
          .add(invitation.toMap());
    } catch (e) {
      debugPrint("Error on create invitation: $e");
      rethrow;
    }
  }

  Future<List<Invitation>> getByRecipient(String email) async {
    try {
      final snapshot = await _firestore
          .collection(collection)
          .where('recipient', isEqualTo: email)
          .get();

      return snapshot.docs.map((doc) {
        return Invitation.fromMap(doc.id, doc.data());
      }).toList();
    } catch (e) {
      debugPrint("Error on get invitations by recipient: $e");
      return [];
    }
  }

  Future<void> delete(String invitationId) async {
    try {
      await _firestore
          .collection(collection)
          .doc(invitationId)
          .delete();
    } catch (e) {
      debugPrint("Error on delete invitation: $e");
      rethrow;
    }
  }

  Future<bool> recipientExists(String email) async {
    try {
      final snapshot = await _firestore
          .collection("users")
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint("Error checking if recipient exists: $e");
      return false;
    }
  }

  /// Stream de convites filtrados por destinatário, em tempo real.
  Stream<List<Invitation>> streamByRecipient(String email) {
    return _firestore
        .collection(collection)
        .where('recipient', isEqualTo: email)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Invitation.fromMap(doc.id, doc.data()))
            .toList());
  }
}
