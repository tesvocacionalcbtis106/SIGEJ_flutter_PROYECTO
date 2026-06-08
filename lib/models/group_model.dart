class GroupModel {
  const GroupModel({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  GroupModel copyWith({String? id, String? name}) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  factory GroupModel.fromMap(Map<String, dynamic> map, String documentId) {
    return GroupModel(
      id: documentId,
      name: map['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}

