import 'package:flutter/foundation.dart';

import '../../models/group_model.dart';
import '../../models/justification_model.dart';
import '../../models/record_model.dart';
import '../../models/role_model.dart';
import '../../models/student_model.dart';
import '../../models/teacher_model.dart';
import '../../models/user_model.dart';

class LocalDatabase extends ChangeNotifier {
  final List<UserModel> _users = [];
  final List<GroupModel> _groups = [];
  final List<StudentModel> _students = [];
  final List<TeacherModel> _teachers = [];
  final List<JustificationModel> _justifications = [];
  final Map<String, String> _passwords = {};

  Future<void> init() async {
    if (_users.isNotEmpty) return;

    _groups.addAll([
      const GroupModel(id: '1', name: '1°A'),
      const GroupModel(id: '2', name: '1°B'),
      const GroupModel(id: '3', name: '1°C'),
      const GroupModel(id: '4', name: '2°A'),
      const GroupModel(id: '5', name: '2°B'),
      const GroupModel(id: '6', name: '2°C'),
      const GroupModel(id: '7', name: '3°A'),
      const GroupModel(id: '8', name: '3°B'),
    ]);

    _users.addAll([
      const UserModel(
        id: '1',
        username: 'superadmin',
        email: 'superadmin@sigej.local',
        fullName: 'Super Administrador',
        role: UserRole.superAdmin,
      ),
      const UserModel(
        id: '2',
        username: 'admin',
        email: 'admin@sigej.local',
        fullName: 'Administrador General',
        role: UserRole.admin,
      ),
      const UserModel(
        id: '3',
        username: 'subdir',
        email: 'subdir@sigej.local',
        fullName: 'Subdireccion',
        role: UserRole.admin,
      ),
      const UserModel(
        id: '4',
        username: 'maestro1',
        email: 'maestro1@sigej.local',
        fullName: 'Prof. Ramirez Garcia, Jose',
        role: UserRole.maestro,
        groupIds: ['1', '2', '3'],
      ),
      const UserModel(
        id: '5',
        username: 'maestro2',
        email: 'maestro2@sigej.local',
        fullName: 'Prof. Torres Vidal, Elena',
        role: UserRole.maestro,
        groupIds: ['2', '4', '6'],
      ),
    ]);

    _passwords.addAll({
      'superadmin': 'super2024',
      'admin': 'admin123',
      'subdir': 'subdir456',
      'maestro1': 'maestro123',
      'maestro2': 'maestro123',
      'maestro3': 'maestro123',
      'maestro6': 'maestro123',
    });

    _teachers.addAll([
      const TeacherModel(
        id: '4',
        name: 'Prof. Ramirez Garcia, Jose',
        username: 'maestro1',
        groupIds: ['1', '2', '3'],
      ),
      const TeacherModel(
        id: '5',
        name: 'Prof. Torres Vidal, Elena',
        username: 'maestro2',
        groupIds: ['2', '4', '6'],
      ),
      const TeacherModel(
        id: '6',
        name: 'Prof. Mendoza Cruz, Roberto',
        username: 'maestro3',
        groupIds: ['4', '5', '6'],
      ),
      const TeacherModel(
        id: '7',
        name: 'Prof. Navarro Rios, Patricia',
        username: 'maestro6',
        groupIds: ['7', '8'],
      ),
    ]);

    _seedStudents();
    _justifications.addAll([
      const JustificationModel(
        id: '1',
        studentId: '1',
        startDate: '2026-06-03',
        endDate: '2026-06-03',
        allDay: true,
        reason: 'Cita medica',
        createdBy: 'Administrador General',
        createdAt: '2026-06-03 08:30',
      ),
      const JustificationModel(
        id: '2',
        studentId: '25',
        startDate: '2026-06-04',
        endDate: '2026-06-05',
        allDay: false,
        startTime: '09:00',
        endTime: '12:00',
        reason: 'Tramite oficial',
        createdBy: 'Subdireccion',
        createdAt: '2026-06-04 10:15',
      ),
    ]);
  }

  List<UserModel> get users => List.unmodifiable(_users);
  List<UserModel> get admins =>
      _users.where((user) => user.role == UserRole.admin).toList();
  List<GroupModel> get groups => List.unmodifiable(_groups);
  List<StudentModel> get students => List.unmodifiable(_students);
  List<TeacherModel> get teachers => List.unmodifiable(_teachers);
  List<JustificationModel> get justifications => List.unmodifiable(_justifications);

  List<RecordModel> get records {
    return _justifications
        .map(
          (item) => RecordModel(
            id: item.id,
            title: studentName(item.studentId),
            status: item.allDay ? 'Todo el dia' : '${item.startTime} - ${item.endTime}',
            createdAt: DateTime.tryParse(item.startDate) ?? DateTime.now(),
          ),
        )
        .toList();
  }

  List<StudentModel> studentsByGroup(String groupId) {
    return _students.where((student) => student.groupId == groupId).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
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
        .firstWhere((group) => group.id == groupId, orElse: () => const GroupModel(id: '', name: '-'))
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

  UserModel? authenticate(String username, String password) {
    if (_passwords[username.trim()] != password.trim()) return null;

    return _users
        .where((user) => user.username == username.trim() && user.isActive)
        .firstOrNull;
  }

  void saveUser(UserModel user) {
    final index = _users.indexWhere((item) => item.id == user.id);
    if (index >= 0) {
      _users[index] = user;
    } else {
      _users.add(user);
    }
  }

  void addAdmin({
    required String name,
    required String username,
    required String password,
  }) {
    final cleanName = name.trim();
    final cleanUsername = username.trim();
    final cleanPassword = password.trim();
    if (cleanName.isEmpty || cleanUsername.isEmpty || cleanPassword.isEmpty) {
      return;
    }
    if (_users.any((user) => user.username == cleanUsername)) return;
    final id = _nextId(_users.map((item) => item.id));
    _users.add(
      UserModel(
        id: id,
        username: cleanUsername,
        email: cleanUsername,
        fullName: cleanName,
        role: UserRole.admin,
      ),
    );
    _passwords[cleanUsername] = cleanPassword;
    notifyListeners();
  }

  void changeAdminPassword(String adminId, String password) {
    if (password.trim().length < 4) return;
    final admin = _users.where((user) => user.id == adminId).firstOrNull;
    if (admin == null || admin.role != UserRole.admin) return;
    _passwords[admin.username] = password.trim();
    notifyListeners();
  }

  void deleteAdmin(String adminId) {
    final admin = _users.where((user) => user.id == adminId).firstOrNull;
    if (admin == null || admin.role != UserRole.admin) return;
    _passwords.remove(admin.username);
    _users.removeWhere((user) => user.id == adminId);
    notifyListeners();
  }

  void addGroup(String name) {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return;
    if (_groups.any((group) => group.name.toLowerCase() == cleanName.toLowerCase())) {
      return;
    }
    _groups.add(GroupModel(id: _nextId(_groups.map((item) => item.id)), name: cleanName));
    notifyListeners();
  }

  void editGroup(String groupId, String name) {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return;
    final index = _groups.indexWhere((group) => group.id == groupId);
    if (index < 0) return;
    _groups[index] = GroupModel(id: groupId, name: cleanName);
    notifyListeners();
  }

  void deleteGroup(String groupId) {
    _groups.removeWhere((group) => group.id == groupId);
    final studentIds = _students
        .where((student) => student.groupId == groupId)
        .map((student) => student.id)
        .toSet();
    _students.removeWhere((student) => student.groupId == groupId);
    _justifications.removeWhere((item) => studentIds.contains(item.studentId));
    for (var i = 0; i < _teachers.length; i++) {
      final teacher = _teachers[i];
      _teachers[i] = TeacherModel(
        id: teacher.id,
        name: teacher.name,
        username: teacher.username,
        groupIds: teacher.groupIds.where((id) => id != groupId).toList(),
      );
    }
    for (var i = 0; i < _users.length; i++) {
      final user = _users[i];
      if (user.role == UserRole.maestro) {
        _users[i] = user.copyWith(
          groupIds: user.groupIds.where((id) => id != groupId).toList(),
        );
      }
    }
    notifyListeners();
  }

  void addStudent(String groupId, String name) {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return;
    _students.add(
      StudentModel(
        id: _nextId(_students.map((item) => item.id)),
        name: cleanName,
        groupId: groupId,
      ),
    );
    notifyListeners();
  }

  void editStudent(String studentId, String name) {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return;
    final index = _students.indexWhere((student) => student.id == studentId);
    if (index < 0) return;
    final current = _students[index];
    _students[index] = StudentModel(
      id: current.id,
      name: cleanName,
      groupId: current.groupId,
    );
    notifyListeners();
  }

  void deleteStudent(String studentId) {
    _students.removeWhere((student) => student.id == studentId);
    _justifications.removeWhere((item) => item.studentId == studentId);
    notifyListeners();
  }

  void addJustification({
    required String studentId,
    required String startDate,
    required String endDate,
    required bool allDay,
    String? startTime,
    String? endTime,
    String? reason,
    required String createdBy,
  }) {
    _justifications.add(
      JustificationModel(
        id: _nextId(_justifications.map((item) => item.id)),
        studentId: studentId,
        startDate: startDate,
        endDate: endDate,
        allDay: allDay,
        startTime: allDay ? null : startTime,
        endTime: allDay ? null : endTime,
        reason: reason?.trim().isEmpty == true ? null : reason?.trim(),
        createdBy: createdBy,
        createdAt: DateTime.now().toString().substring(0, 16),
      ),
    );
    notifyListeners();
  }

  void addTeacher({
    required String name,
    required String username,
    required String password,
    required List<String> groupIds,
  }) {
    final cleanName = name.trim();
    final cleanUsername = username.trim();
    if (cleanName.isEmpty || cleanUsername.isEmpty || password.trim().isEmpty) return;
    if (_users.any((user) => user.username == cleanUsername)) return;
    final id = _nextId(_users.map((item) => item.id));
    _users.add(
      UserModel(
        id: id,
        username: cleanUsername,
        email: cleanUsername,
        fullName: cleanName,
        role: UserRole.maestro,
        groupIds: groupIds,
      ),
    );
    _teachers.add(
      TeacherModel(
        id: id,
        name: cleanName,
        username: cleanUsername,
        groupIds: groupIds,
      ),
    );
    _passwords[cleanUsername] = password.trim();
    notifyListeners();
  }

  void updateTeacherGroups(String teacherId, List<String> groupIds) {
    final teacherIndex = _teachers.indexWhere((teacher) => teacher.id == teacherId);
    if (teacherIndex < 0 || groupIds.isEmpty) return;
    final teacher = _teachers[teacherIndex];
    _teachers[teacherIndex] = TeacherModel(
      id: teacher.id,
      name: teacher.name,
      username: teacher.username,
      groupIds: groupIds,
    );
    final userIndex = _users.indexWhere((user) => user.id == teacherId);
    if (userIndex >= 0) {
      _users[userIndex] = _users[userIndex].copyWith(groupIds: groupIds);
    }
    notifyListeners();
  }

  void changeTeacherPassword(String teacherId, String password) {
    if (password.trim().length < 4) return;
    final teacher = _teachers
        .where((teacher) => teacher.id == teacherId)
        .firstOrNull;
    if (teacher == null) return;
    _passwords[teacher.username] = password.trim();
    notifyListeners();
  }

  void deleteTeacher(String teacherId) {
    final teacher = _teachers
        .where((item) => item.id == teacherId)
        .firstOrNull;
    if (teacher != null) {
      _passwords.remove(teacher.username);
    }
    _teachers.removeWhere((teacher) => teacher.id == teacherId);
    _users.removeWhere((user) => user.id == teacherId);
    notifyListeners();
  }

  void _seedStudents() {
    final names = {
      '1': [
        'Avila Torres, Carlos',
        'Castellanos Ruiz, Emiliano',
        'Cruz Mendoza, Sofia',
        'Delgado Sanchez, Valentina',
        'Dominguez Flores, Andres',
      ],
      '2': [
        'Alvarado Mendez, Ximena',
        'Bautista Guerrero, Alexis',
        'Benitez Salinas, Natalia',
        'Campos Nunez, Emilio',
        'Cervantes Rojas, Alejandra',
      ],
      '3': [
        'Acosta Pena, Brenda',
        'Alvarez Mora, Carlos',
        'Arroyo Jimenez, Diana',
        'Barron Soto, Eduardo',
        'Bustos Reyes, Fernanda',
      ],
      '4': [
        'Aguilar Bravo, Stephanie',
        'Aragon Tellez, Hector',
        'Arellano Soto, Monserrat',
        'Balderas Quiroz, Luis',
        'Camacho Elizondo, Diana',
      ],
      '5': [
        'Amador Leyva, Brenda',
        'Barrera Ponce, Cristian',
        'Becerra Noriega, Silvia',
        'Bonilla Trujillo, Marco',
        'Cabrera Infante, Adriana',
      ],
      '6': [
        'Aguilera Sanchez, Ana',
        'Becerril Torres, Benjamin',
        'Cabello Diaz, Carmen',
        'Davila Rojas, Daniel',
        'Elizarraraz Vega, Elena',
      ],
      '7': [
        'Aguinaga Torres, Adriana',
        'Basurto Vidal, Armando',
        'Castellon Ruiz, Beatriz',
        'Chavez Morales, Cesar',
        'De Leon Herrera, Claudia',
      ],
      '8': [
        'Abundis Rios, Alejandro',
        'Baeza Trejo, Alicia',
        'Barrios Nunez, Alonso',
        'Ceballos Vega, Ana Karen',
        'Cienfuegos Mora, Arturo',
      ],
    };

    var id = 1;
    for (final entry in names.entries) {
      for (final name in entry.value) {
        _students.add(
          StudentModel(id: '${id++}', name: name, groupId: entry.key),
        );
      }
    }
  }

  String _nextId(Iterable<String> ids) {
    final parsed = ids.map((id) => int.tryParse(id) ?? 0);
    final next = parsed.isEmpty ? 1 : parsed.reduce((a, b) => a > b ? a : b) + 1;
    return '$next';
  }
}
