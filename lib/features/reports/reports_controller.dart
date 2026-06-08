import 'package:flutter/foundation.dart';

import '../../data/repositories/records_repository.dart';
import '../../models/record_model.dart';

class ReportsController extends ChangeNotifier {
  ReportsController(this._repository);

  final RecordsRepository _repository;

  List<RecordModel> records = [];

  Future<void> load() async {
    records = await _repository.getRecords();
    notifyListeners();
  }
}
