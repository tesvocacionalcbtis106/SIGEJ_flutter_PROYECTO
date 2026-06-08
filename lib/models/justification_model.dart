class JustificationModel {
  const JustificationModel({
    required this.id,
    required this.studentId,
    required this.startDate,
    required this.endDate,
    required this.allDay,
    this.startTime,
    this.endTime,
    this.reason,
    required this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String studentId;
  final String startDate;
  final String endDate;
  final bool allDay;
  final String? startTime;
  final String? endTime;
  final String? reason;
  final String createdBy;
  final String createdAt;

  JustificationModel copyWith({
    String? id,
    String? studentId,
    String? startDate,
    String? endDate,
    bool? allDay,
    String? startTime,
    String? endTime,
    String? reason,
    String? createdBy,
    String? createdAt,
  }) {
    return JustificationModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      allDay: allDay ?? this.allDay,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      reason: reason ?? this.reason,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory JustificationModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return JustificationModel(
      id: documentId,
      studentId: map['studentId'] ?? '',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
      allDay: map['allDay'] ?? false,
      startTime: map['startTime'],
      endTime: map['endTime'],
      reason: map['reason'],
      createdBy: map['createdBy'] ?? '',
      createdAt: map['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'startDate': startDate,
      'endDate': endDate,
      'allDay': allDay,
      'startTime': startTime,
      'endTime': endTime,
      'reason': reason,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }
}

