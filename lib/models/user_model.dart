import 'role_model.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    this.groupIds = const [],
    this.isActive = true,
  });

  final String id;
  final String username;
  final String fullName;
  final UserRole role;
  final List<String> groupIds;
  final bool isActive;

  UserModel copyWith({
    String? id,
    String? username,
    String? fullName,
    UserRole? role,
    List<String>? groupIds,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      groupIds: groupIds ?? this.groupIds,
      isActive: isActive ?? this.isActive,
    );
  }


  /// Convierte Firestore -> UserModel
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      username: map['username'] ?? '',
      fullName: map['fullName'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.admin,
      ),
      groupIds: List<String>.from(map['groupIds'] ?? []),
      isActive: map['isActive'] ?? true,
    );
  }

  /// Convierte UserModel -> Firestore
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'fullName': fullName,
      'role': role.name,
      'groupIds': groupIds,
      'isActive': isActive,
    };
  }
}