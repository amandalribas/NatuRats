import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/report.dart';
import '../service/report_service.dart';

class ReportController extends ChangeNotifier {
  final ReportService _service;
  final String groupId;
  final String activityId;
  final String targetType;
  final String targetUserId;
  final String targetName;

  ReportType? _selectedType;
  String _description = '';
  bool _isLoading = false;
  String? _errorMessage;

  ReportController({
    required ReportService service,
    required this.groupId,
    required this.activityId,
    required this.targetType,
    required this.targetUserId,
    required this.targetName,
  }) : _service = service;

  ReportType? get selectedType => _selectedType;
  String get description => _description;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// Retorna o UID do usuário atual (usado pela ReportPage para checar limite).
  Future<String?> getCurrentUserUid() async {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  void selectType(ReportType type) {
    _selectedType = type;
    notifyListeners();
  }

  void updateDescription(String text) {
    _description = text;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> submitReport() async {
    if (_selectedType == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.submitReport(
        groupId: groupId,
        activityId: activityId,
        targetType: targetType,
        type: _selectedType!,
        description: _description,
        targetUserId: targetUserId,
        targetName: targetName,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _selectedType = null;
    _description = '';
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}