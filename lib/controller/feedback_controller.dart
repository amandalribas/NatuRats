import 'package:flutter/material.dart' hide Feedback;
import '../model/feedback.dart';
import '../service/feedback_service.dart';

class FeedbackController extends ChangeNotifier {
  final FeedbackService _service;

  Feedback? _existingFeedback;
  bool _isLoading = false;
  String? _errorMessage;

  double _rating = 0.0;       
  String _commentText = '';
  bool _isEditingForm = false;   

  FeedbackController({FeedbackService? service})
      : _service = service ?? FeedbackService();


  Feedback? get existingFeedback => _existingFeedback;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get rating => _rating;
  String get commentText => _commentText;
  bool get hasFeedback => _existingFeedback != null;
  bool get isEditingForm => _isEditingForm;


  void startEditing() {
    _isEditingForm = true;
    if (_existingFeedback != null) {
      _rating = _existingFeedback!.rating;
      _commentText = _existingFeedback!.comment ?? '';
    }
    notifyListeners();
  }


  void cancelEditing() {
    _isEditingForm = false;

    if (_existingFeedback != null) {
      _rating = _existingFeedback!.rating;
      _commentText = _existingFeedback!.comment ?? '';
    }
    notifyListeners();
  }

  void setComment(String value) {
    _commentText = value;
    notifyListeners();
  }

  void setRating(double newRating) {
    _rating = newRating;
    notifyListeners();
  }

  Future<void> loadFeedback() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _existingFeedback = await _service.getMyFeedback();
      final fb = _existingFeedback;
      if (fb != null) {
        _rating = fb.rating;
        _commentText = fb.comment ?? '';
        _isEditingForm = false; 
      } else {
        _isEditingForm = true; 
      }
    } catch (e) {
      _errorMessage = 'Erro ao carregar feedback.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitFeedback() async {
    if (_rating == 0.0) {
      _errorMessage = 'Por favor, selecione uma nota.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final comment = _commentText.trim().isEmpty ? null : _commentText.trim();
      if (_existingFeedback != null) {
        await _service.updateFeedback(_rating, comment);
      } else {
        await _service.submitFeedback(_rating, comment);
      }
      await loadFeedback(); // recarrega e sai do modo edição
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao enviar feedback.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteFeedback() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.deleteMyFeedback();
      _existingFeedback = null;
      _rating = 0.0;
      _commentText = '';
      _isEditingForm = true; 
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao excluir feedback.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}