import 'package:flutter/foundation.dart';

import '../../data/repositories/records_repository.dart';
import '../../models/record_model.dart';

class DashboardController extends ChangeNotifier {
  DashboardController(this._repository);

  final RecordsRepository _repository;

  List<RecordModel> records = [];
  bool isLoading = false;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    records = await _repository.getRecords();
    isLoading = false;
    notifyListeners();
  }
}
