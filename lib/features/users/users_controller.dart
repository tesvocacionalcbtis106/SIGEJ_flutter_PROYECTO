import 'package:flutter/foundation.dart';

import '../../data/repositories/users_repository.dart';
import '../../models/user_model.dart';

class UsersController extends ChangeNotifier {
  UsersController(this._repository);

  final UsersRepository _repository;

  List<UserModel> users = [];

  Future<void> load() async {
    users = await _repository.getUsers();
    notifyListeners();
  }

  Future<void> save(UserModel user) async {
    await _repository.saveUser(user);
    await load();
  }
}
