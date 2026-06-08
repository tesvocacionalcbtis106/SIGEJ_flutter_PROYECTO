import '../firebase/firestore_service.dart';
import '../../models/justification_model.dart';
import '../../models/record_model.dart';

class RecordsRepository {
  RecordsRepository({FirestoreService? firestoreService})
      : _firestore = firestoreService ?? FirestoreService.instance;

  final FirestoreService _firestore;

  Future<List<RecordModel>> getRecords() async {
    final snapshot = await _firestore.justifications.get();

    final justifications = snapshot.docs
        .map(
          (doc) => JustificationModel.fromMap(
            doc.data(),
            doc.id,
          ),
        )
        .toList();

    return justifications
        .map(
          (item) => RecordModel(
            id: item.id,
            title: item.studentId,
            status:
                item.allDay ? 'Todo el dia' : '${item.startTime} - ${item.endTime}',
            createdAt: DateTime.tryParse(item.startDate) ?? DateTime.now(),
          ),
        )
        .toList();
  }
}

