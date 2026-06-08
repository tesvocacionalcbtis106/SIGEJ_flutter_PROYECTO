import '../../models/justification_model.dart';
import '../../models/record_model.dart';
import '../../models/student_model.dart';
import '../firebase/firestore_service.dart';

class GroupJustificationsResult {
  const GroupJustificationsResult({
    required this.justifications,
    required this.studentNames,
  });

  final List<JustificationModel> justifications;
  final Map<String, String> studentNames;
}

class RecordsRepository {
  RecordsRepository({FirestoreService? firestoreService})
      : _firestore = firestoreService ?? FirestoreService.instance;

  final FirestoreService _firestore;

  Future<List<RecordModel>> getRecords() async {
    final results = await Future.wait([
      _firestore.justifications.get(),
      _firestore.students.get(),
    ]);

    final justifications = results[0].docs
        .map(
          (doc) => JustificationModel.fromMap(
            doc.data(),
            doc.id,
          ),
        )
        .toList();

    final students = results[1].docs
        .map((doc) => StudentModel.fromMap(doc.data(), doc.id))
        .toList();
    final studentNames = {
      for (final student in students) student.id: student.name,
    };

    return justifications
        .map(
          (item) => RecordModel(
            id: item.id,
            title: studentNames[item.studentId] ?? item.studentId,
            status:
                item.allDay ? 'Todo el dia' : '${item.startTime} - ${item.endTime}',
            createdAt: DateTime.tryParse(item.startDate) ?? DateTime.now(),
          ),
        )
        .toList();
  }

  Future<GroupJustificationsResult> getJustificationsByGroup(
    String groupId,
  ) async {
    final studentsSnapshot = await _firestore.students
        .where('groupId', isEqualTo: groupId)
        .get();
    final students = studentsSnapshot.docs
        .map((doc) => StudentModel.fromMap(doc.data(), doc.id))
        .toList();
    final studentNames = {
      for (final student in students) student.id: student.name,
    };

    if (students.isEmpty) {
      return GroupJustificationsResult(
        justifications: const [],
        studentNames: studentNames,
      );
    }

    final justifications = <JustificationModel>[];
    final studentIds = students.map((student) => student.id).toList();
    for (var i = 0; i < studentIds.length; i += 30) {
      final chunk = studentIds.skip(i).take(30).toList();
      final snapshot = await _firestore.justifications
          .where('studentId', whereIn: chunk)
          .get();
      justifications.addAll(
        snapshot.docs.map(
          (doc) => JustificationModel.fromMap(doc.data(), doc.id),
        ),
      );
    }

    return GroupJustificationsResult(
      justifications: justifications,
      studentNames: studentNames,
    );
  }
}
