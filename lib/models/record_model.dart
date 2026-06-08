class RecordModel {
  const RecordModel({
    required this.id,
    required this.title,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String status;
  final DateTime createdAt;

  RecordModel copyWith({
    String? id,
    String? title,
    String? status,
    DateTime? createdAt,
  }) {
    return RecordModel(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory RecordModel.fromMap(Map<String, dynamic> map, String documentId) {
    return RecordModel(
      id: documentId,
      title: map['title'] ?? '',
      status: map['status'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

