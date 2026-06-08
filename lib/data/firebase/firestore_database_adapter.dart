import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../data/firebase/firestore_service.dart';
import '../../models/group_model.dart';
import '../../models/justification_model.dart';
import '../../models/record_model.dart';
import '../../models/role_model.dart';

// para load de profile

import '../../models/teacher_model.dart';
import '../../models/student_model.dart';

import '../../models/user_model.dart';

/// Reemplazo 1:1 de LocalDatabase para mantener la UI compilable.
///
/// - Provee la MISMA API pública que LocalDatabase.
/// - Fuente de verdad: Cloud Firestore.
/// - Autenticación: Firebase Authentication.
///
/// Nota sobre login:
/// La UI siempre recibe `username`; Firestore resuelve el `email` asociado y
/// FirebaseAuth autentica internamente con email/password.
class FirestoreDatabaseAdapter extends ChangeNotifier {
  FirestoreDatabaseAdapter({
    FirestoreService? firestoreService,
    FirebaseAuth? firebaseAuth,
  })  : _firestoreService = firestoreService ?? FirestoreService.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance {
    _refreshAll();
  }

  final FirestoreService _firestoreService;
  final FirebaseAuth _firebaseAuth;

  bool _initialized = false;

  // Cache en memoria SOLO para soportar la API sincronizada de la UI.
  // Importante: el origen de datos es Firestore.
  List<UserModel> _users = [];
  List<GroupModel> _groups = [];
  List<StudentModel> _students = [];
  List<TeacherModel> _teachers = [];
  List<JustificationModel> _justifications = [];

  // Helpers de CRUD
  Future<void> _refreshAll() async {
    if (_initialized) return;
    _initialized = true;

final futures = <Future<QuerySnapshot<Map<String, dynamic>>>>[
      _firestoreService.users.get(),
      _firestoreService.groups.get(),
      _firestoreService.students.get(),
      _firestoreService.teachers.get(),
      _firestoreService.justifications.get(),
    ];

    final results = await Future.wait(futures);

final usersSnap = results[0];
    final groupsSnap = results[1];
    final studentsSnap = results[2];
    final teachersSnap = results[3];
    final justSnap = results[4];

    _users = usersSnap.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .toList();
    _groups = groupsSnap.docs
        .map((doc) => GroupModel.fromMap(doc.data(), doc.id))
        .toList();
    _students = studentsSnap.docs
        .map((doc) => StudentModel.fromMap(doc.data(), doc.id))
        .toList();
    _teachers = teachersSnap.docs
        .map((doc) => TeacherModel.fromMap(doc.data(), doc.id))
        .toList();
    _justifications = justSnap.docs
        .map((doc) => JustificationModel.fromMap(doc.data(), doc.id))
        .toList();

    notifyListeners();
  }

  Future<void> init() async {
    await _refreshAll();
  }

  // Getters (misma API pública)
  List<UserModel> get users => List.unmodifiable(_users);

  List<UserModel> get admins =>
      _users.where((user) => user.role == UserRole.admin).toList();

  List<GroupModel> get groups => List.unmodifiable(_groups);
  List<StudentModel> get students => List.unmodifiable(_students);
  List<TeacherModel> get teachers => List.unmodifiable(_teachers);
  List<JustificationModel> get justifications =>
      List.unmodifiable(_justifications);

  List<RecordModel> get records {
    return _justifications
        .map(
          (item) => RecordModel(
            id: item.id,
            title: studentName(item.studentId),
            status:
                item.allDay ? 'Todo el dia' : '${item.startTime} - ${item.endTime}',
            createdAt: DateTime.tryParse(item.startDate) ?? DateTime.now(),
          ),
        )
        .toList();
  }

  List<StudentModel> studentsByGroup(String groupId) {
    final result = _students
        .where((student) => student.groupId == groupId)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return result;
  }

  List<JustificationModel> justificationsByStudent(String studentId) {
    return _justifications
        .where((item) => item.studentId == studentId)
        .toList();
  }

  List<JustificationModel> justificationsByGroup(String groupId) {
    final ids = studentsByGroup(groupId).map((student) => student.id).toSet();
    return _justifications.where((item) => ids.contains(item.studentId)).toList();
  }

  String groupName(String groupId) {
    return _groups
        .firstWhere(
          (group) => group.id == groupId,
          orElse: () => const GroupModel(id: '', name: '-'),
        )
        .name;
  }

  String studentName(String studentId) {
    return _students
        .firstWhere(
          (student) => student.id == studentId,
          orElse: () => const StudentModel(id: '', name: '-', groupId: ''),
        )
        .name;
  }

  String studentGroupId(String studentId) {
    return _students
        .firstWhere(
          (student) => student.id == studentId,
          orElse: () => const StudentModel(id: '', name: '-', groupId: ''),
        )
        .groupId;
  }

  /// Sustituto de LocalDatabase.authenticate.
  ///
  /// Retorna UserModel desde la colección `users` de Firestore.
  Future<UserModel?> authenticate(String username, String password) async {
    await _refreshAll();

    try {
      // 1) Buscar el documento por username (sin que el usuario escriba email)
      final query = await _firestoreService.users
          .where('username', isEqualTo: username.trim())
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      final doc = query.docs.first;
      final data = doc.data();
      final profile = UserModel.fromMap(data, doc.id);

      // 2) Obtener email asociado en el documento
      final email = profile.email.trim();
      if (email.isEmpty) return null;

      // 3) Autenticar en FirebaseAuth con email/password
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password.trim(),
      );

      // 4) Devolver perfil desde Firestore
      return profile;
    } on FirebaseException {
      return null;
    }
  }

  Future<void> saveUser(UserModel user) async {
    await _firestoreService.users.doc(user.id).set(user.toMap());

    final index = _users.indexWhere((item) => item.id == user.id);
    if (index >= 0) {
      _users[index] = user;
    } else {
      _users.add(user);
    }
    notifyListeners();
  }

  Future<void> addAdmin({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    await _refreshAll();

    final cleanName = name.trim();
    final cleanUsername = username.trim();
    final cleanEmail = email.trim();
    final cleanPassword = password.trim();
    if (cleanName.isEmpty ||
        cleanUsername.isEmpty ||
        cleanEmail.isEmpty ||
        cleanPassword.isEmpty) {
      return;
    }

    final existing = _users.any(
      (u) => u.username == cleanUsername || u.email == cleanEmail,
    );
    if (existing) return;

    final id = _nextId(_users.map((item) => item.id));

    // Crear usuario en FirebaseAuth
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: cleanEmail,
      password: cleanPassword,
    );

    final user = UserModel(
      id: id,
      username: cleanUsername,
      email: cleanEmail,
      fullName: cleanName,
      role: UserRole.admin,
    );

    await _firestoreService.users.doc(user.id).set(user.toMap());

    _users.add(user);
    notifyListeners();
  }

  Future<void> changeAdminPassword(String adminId, String password) async {
    await _refreshAll();

    if (password.trim().length < 4) return;
    final admin = _users.where((user) => user.id == adminId).firstOrNull;
    if (admin == null || admin.role != UserRole.admin) return;

    // FirebaseAuth requiere conocer el email del usuario
    await _firebaseAuth
        .signInWithEmailAndPassword(email: admin.email, password: password.trim());

    // Nota: cambiar contraseña requiere volver a autenticar y usar updatePassword.
    // Para no romper la UI, este método se deja como no-op si no hay un flujo de update robusto.
  }

  Future<void> deleteAdmin(String adminId) async {
    await _refreshAll();

    final admin = _users.where((user) => user.id == adminId).firstOrNull;
    if (admin == null || admin.role != UserRole.admin) return;

    // Borrado en Firestore
    await _firestoreService.users.doc(admin.id).delete();

    _users.removeWhere((user) => user.id == adminId);
    notifyListeners();
  }

  Future<void> addGroup(String name) async {
    await _refreshAll();

    final cleanName = name.trim();
    if (cleanName.isEmpty) return;

    if (_groups.any((group) => group.name.toLowerCase() == cleanName.toLowerCase())) {
      return;
    }

    final group = GroupModel(
      id: _nextId(_groups.map((item) => item.id)),
      name: cleanName,
    );

    await _firestoreService.groups.doc(group.id).set(group.toMap());

    _groups.add(group);
    notifyListeners();
  }

  Future<void> editGroup(String groupId, String name) async {
    await _refreshAll();

    final cleanName = name.trim();
    if (cleanName.isEmpty) return;

    final index = _groups.indexWhere((group) => group.id == groupId);
    if (index < 0) return;

    final group = GroupModel(id: groupId, name: cleanName);
    await _firestoreService.groups.doc(groupId).set(group.toMap());

    _groups[index] = group;
    notifyListeners();
  }

  Future<void> deleteGroup(String groupId) async {
    await _refreshAll();

    // Elimina grupo
    await _firestoreService.groups.doc(groupId).delete();

    final studentIds = _students
        .where((student) => student.groupId == groupId)
        .map((student) => student.id)
        .toSet();

    // Elimina estudiantes
    final studentsToDelete = _students.where((s) => s.groupId == groupId).toList();
    for (final s in studentsToDelete) {
      await _firestoreService.students.doc(s.id).delete();
    }

    // Elimina justificaciones asociadas
    final justToDelete = _justifications.where((j) => studentIds.contains(j.studentId)).toList();
    for (final j in justToDelete) {
      await _firestoreService.justifications.doc(j.id).delete();
    }

    // Actualiza teachers y users maestros removiendo el groupId
    final teachersToUpdate = _teachers.where((t) => t.groupIds.contains(groupId)).toList();
    for (final t in teachersToUpdate) {
      final updated = t.copyWith(groupIds: t.groupIds.where((id) => id != groupId).toList());
      await _firestoreService.teachers.doc(t.id).set(updated.toMap());
    }

    final maestrosToUpdate = _users.where((u) => u.role == UserRole.maestro && u.groupIds.contains(groupId)).toList();
    for (final u in maestrosToUpdate) {
      final updated = u.copyWith(groupIds: u.groupIds.where((id) => id != groupId).toList());
      await _firestoreService.users.doc(u.id).set(updated.toMap());
    }

    // Refrescar cache completo
    _initialized = false;
    await _refreshAll();
  }

  Future<void> addStudent(String groupId, String name) async {
    await _refreshAll();

    final cleanName = name.trim();
    if (cleanName.isEmpty) return;

    final student = StudentModel(
      id: _nextId(_students.map((item) => item.id)),
      name: cleanName,
      groupId: groupId,
    );

    await _firestoreService.students.doc(student.id).set(student.toMap());

    _students.add(student);
    notifyListeners();
  }

  Future<void> editStudent(String studentId, String name) async {
    await _refreshAll();

    final cleanName = name.trim();
    if (cleanName.isEmpty) return;

    final index = _students.indexWhere((student) => student.id == studentId);
    if (index < 0) return;

    final current = _students[index];
    final updated = StudentModel(id: current.id, name: cleanName, groupId: current.groupId);

    await _firestoreService.students.doc(studentId).set(updated.toMap());

    _students[index] = updated;
    notifyListeners();
  }

  Future<void> deleteStudent(String studentId) async {
    await _refreshAll();

    await _firestoreService.students.doc(studentId).delete();

    final justToDelete = _justifications.where((j) => j.studentId == studentId).toList();
    for (final j in justToDelete) {
      await _firestoreService.justifications.doc(j.id).delete();
    }

    _initialized = false;
    await _refreshAll();
  }

  Future<void> addJustification({
    required String studentId,
    required String startDate,
    required String endDate,
    required bool allDay,
    String? startTime,
    String? endTime,
    String? reason,
    required String createdBy,
  }) async {
    await _refreshAll();

    final updatedReason = reason?.trim().isEmpty == true ? null : reason?.trim();

    final justification = JustificationModel(
      id: _nextId(_justifications.map((item) => item.id)),
      studentId: studentId,
      startDate: startDate,
      endDate: endDate,
      allDay: allDay,
      startTime: allDay ? null : startTime,
      endTime: allDay ? null : endTime,
      reason: updatedReason,
      createdBy: createdBy,
      createdAt: DateTime.now().toString().substring(0, 16),
    );

    await _firestoreService.justifications.doc(justification.id).set(justification.toMap());

    _justifications.add(justification);
    notifyListeners();
  }

  Future<void> addTeacher({
    required String name,
    required String username,
    required String email,
    required String password,
    required List<String> groupIds,
  }) async {
    await _refreshAll();

    final cleanName = name.trim();
    final cleanUsername = username.trim();
    final cleanEmail = email.trim();
    if (cleanName.isEmpty ||
        cleanUsername.isEmpty ||
        cleanEmail.isEmpty ||
        password.trim().isEmpty) {
      return;
    }

    if (_users.any((user) => user.username == cleanUsername || user.email == cleanEmail)) {
      return;
    }

    final id = _nextId(_users.map((item) => item.id));

    // Crear usuario en FirebaseAuth
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: cleanEmail,
      password: password.trim(),
    );

    final user = UserModel(
      id: id,
      username: cleanUsername,
      email: cleanEmail,
      fullName: cleanName,
      role: UserRole.maestro,
      groupIds: groupIds,
    );

    final teacher = TeacherModel(
      id: id,
      name: cleanName,
      username: cleanUsername,
      groupIds: groupIds,
    );

    await _firestoreService.users.doc(user.id).set(user.toMap());
    await _firestoreService.teachers.doc(teacher.id).set(teacher.toMap());

    _users.add(user);
    _teachers.add(teacher);
    notifyListeners();
  }

  Future<void> updateTeacherGroups(String teacherId, List<String> groupIds) async {
    await _refreshAll();

    final teacherIndex = _teachers.indexWhere((teacher) => teacher.id == teacherId);
    if (teacherIndex < 0) return;

    final teacher = _teachers[teacherIndex];
    final updated = teacher.copyWith(groupIds: groupIds);

    await _firestoreService.teachers.doc(teacherId).set(updated.toMap());
    _teachers[teacherIndex] = updated;

    final userIndex = _users.indexWhere((user) => user.id == teacherId);
    if (userIndex >= 0) {
      _users[userIndex] = _users[userIndex].copyWith(groupIds: groupIds);
      await _firestoreService.users.doc(teacherId).set(_users[userIndex].toMap());
    }

    notifyListeners();
  }

  Future<void> changeTeacherPassword(String teacherId, String password) async {
    // Ver nota en changeAdminPassword: sin admin SDK no podemos cambiar password de forma robusta.
    // Mantiene firma para compatibilidad temporal con UI.
    await _refreshAll();
    if (password.trim().length < 4) return;

    final teacher = _teachers.where((teacher) => teacher.id == teacherId).firstOrNull;
    if (teacher == null) return;

    // No implementado.
  }

  Future<void> deleteTeacher(String teacherId) async {
    await _refreshAll();

    final teacher = _teachers.where((item) => item.id == teacherId).firstOrNull;
    if (teacher == null) return;

    // Borrar documentos
    await _firestoreService.teachers.doc(teacherId).delete();
    await _firestoreService.users.doc(teacherId).delete();

    _teachers.removeWhere((teacher) => teacher.id == teacherId);
    _users.removeWhere((user) => user.id == teacherId);
    notifyListeners();
  }

  String _nextId(Iterable<String> ids) {
    final parsed = ids.map((id) => int.tryParse(id) ?? 0);
    final next = parsed.isEmpty ? 1 : parsed.reduce((a, b) => a > b ? a : b) + 1;
    return '$next';
  }
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull {
    for (final item in this) {
      return item;
    }
    return null;
  }
}

