class TeacherModel {
  const TeacherModel({
    required this.id,
    required this.name,
    required this.username,
    required this.groupIds,
  });

  final String id;
  final String name;
  final String username;
  final List<String> groupIds;

  TeacherModel copyWith({
    String? id,
    String? name,
    String? username,
    List<String>? groupIds,
  }) {
    return TeacherModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      groupIds: groupIds ?? this.groupIds,
    );
  }

  factory TeacherModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TeacherModel(
      id: documentId,
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      groupIds: List<String>.from(map['groupIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'groupIds': groupIds,
    };
  }
}

