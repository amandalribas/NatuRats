import 'package:firebase_auth/firebase_auth.dart';
import 'package:naturats/model/feedback.dart';
import 'package:naturats/repository/feedback_repository.dart';

class FeedbackService {
  final FeedbackRepository _repository;
  final String Function() _userIdProvider;

  FeedbackService({
    FeedbackRepository? repository,
    String Function()? userIdProvider,
  })  : _repository = repository ?? FeedbackRepository(),
        _userIdProvider = userIdProvider ??
            (() => FirebaseAuth.instance.currentUser!.uid);

  Future<Feedback?> getMyFeedback() async {
    final uid = _userIdProvider();
    return _repository.getFeedback(uid);
  }

  Future<void> submitFeedback(double rating, String? comment) async {
    final uid = _userIdProvider();
    final now = DateTime.now();
    final fb = Feedback(
      userId: uid,
      rating: rating,
      comment: comment,
      createdAt: now,
      updatedAt: now,
    );
    await _repository.createFeedback(fb);
  }

  Future<void> updateFeedback(double rating, String? comment) async {
    final uid = _userIdProvider();
    final now = DateTime.now();
    final fb = Feedback(
      userId: uid,
      rating: rating,
      comment: comment,
      updatedAt: now,
    );
    await _repository.updateFeedback(fb);
  }

  Future<void> deleteMyFeedback() async {
    final uid = _userIdProvider();
    await _repository.deleteFeedback(uid);
  }
}