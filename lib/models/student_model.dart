class StudentModel {
  const StudentModel({
    required this.id,
    required this.name,
    required this.groupId,
  });

  final String id;
  final String name;
  final String groupId;

  factory StudentModel.fromMap(
      Map<String, dynamic> map,
      String documentId,
  ) {
    return StudentModel(
      id: documentId,
      name: map["name"] ?? "",
      groupId: map["groupId"] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "groupId": groupId,
    };
  }

  StudentModel copyWith({String? id, String? name, String? groupId}) {
    return StudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      groupId: groupId ?? this.groupId,
    );
  }
}

