class StorageService {
  String? _sessionUserId;

  String? get sessionUserId => _sessionUserId;

  void saveSession(String userId) {
    _sessionUserId = userId;
  }

  void clearSession() {
    _sessionUserId = null;
  }
}
