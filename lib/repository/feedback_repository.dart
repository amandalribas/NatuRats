import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:naturats/model/feedback.dart';

class FeedbackRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'feedbacks';

  FeedbackRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Obtém o feedback do usuário (documento com ID = userId)
  Future<Feedback?> getFeedback(String userId) async {
    final doc = await _firestore.collection(_collection).doc(userId).get();
    if (!doc.exists) return null;
    return Feedback.fromMap(doc.data()!);
  }

  /// Cria um novo feedback (documento com ID = userId)
  Future<void> createFeedback(Feedback feedback) async {
    await _firestore
        .collection(_collection)
        .doc(feedback.userId!)
        .set(feedback.toMap());
  }

  /// Atualiza o feedback existente
  Future<void> updateFeedback(Feedback feedback) async {
    await _firestore
        .collection(_collection)
        .doc(feedback.userId!)
        .update(feedback.toMap());
  }

  /// Exclui o feedback do usuário
  Future<void> deleteFeedback(String userId) async {
    await _firestore.collection(_collection).doc(userId).delete();
  }
}