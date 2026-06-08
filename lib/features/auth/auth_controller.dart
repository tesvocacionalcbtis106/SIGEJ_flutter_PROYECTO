import 'package:flutter/foundation.dart';

import '../../data/repositories/auth_repository.dart';
import '../../models/user_model.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._repository);

  final AuthRepository _repository;

  UserModel? currentUser;
  bool isLoading = false;
  String? error;

  bool get isAuthenticated => currentUser != null;

  Future<bool> login(String username, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();

    currentUser = await _repository.login(username, password);
    isLoading = false;

    if (currentUser == null) {
      error = 'Usuario o contrasena incorrectos';
      notifyListeners();
      return false;
    }

    notifyListeners();
    return true;
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }
}
