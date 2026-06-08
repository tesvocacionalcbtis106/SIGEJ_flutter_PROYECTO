import 'package:flutter/foundation.dart';

import '../../data/repositories/records_repository.dart';
import '../../models/justification_model.dart';
import '../../models/record_model.dart';

class ReportsController extends ChangeNotifier {
  ReportsController(this._repository);

  final RecordsRepository _repository;

  List<RecordModel> records = [];
  List<JustificationModel> groupJustifications = [];
  Map<String, String> studentNames = {};
  bool isLoading = false;

  Future<void> load() async {
    records = await _repository.getRecords();
    notifyListeners();
  }

  Future<void> loadByGroup(String groupId) async {
    isLoading = true;
    groupJustifications = [];
    studentNames = {};
    notifyListeners();

    try {
      final result = await _repository.getJustificationsByGroup(groupId);
      groupJustifications = result.justifications;
      studentNames = result.studentNames;
    } catch (_) {
      groupJustifications = [];
      studentNames = {};
    }

    isLoading = false;
    notifyListeners();
  }

  String studentName(String studentId) {
    return studentNames[studentId] ?? '-';
  }
}
