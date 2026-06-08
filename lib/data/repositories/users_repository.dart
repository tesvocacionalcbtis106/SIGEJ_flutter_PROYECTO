import '../../models/user_model.dart';
import '../firebase/firestore_service.dart';

class UsersRepository {
  UsersRepository({FirestoreService? firestoreService})
      : _firestore = firestoreService ?? FirestoreService.instance;

  final FirestoreService _firestore;

  Future<List<UserModel>> getUsers() async {
    final snapshot = await _firestore.users.get();
    return snapshot.docs
        .map(
          (doc) => UserModel.fromMap(
            doc.data(),
            doc.id,
          ),
        )
        .toList();
  }

  Future<void> saveUser(UserModel user) async {
    await _firestore.users.doc(user.id).set(user.toMap());
  }
}

