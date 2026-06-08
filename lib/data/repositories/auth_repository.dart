import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../firebase/firestore_service.dart';
import '../../models/user_model.dart';

class AuthRepository {
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirestoreService? firestoreService,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestoreService ?? FirestoreService.instance;

  final FirebaseAuth _firebaseAuth;
  final FirestoreService _firestore;

  Future<UserModel?> login(
    String username,
    String password,
  ) async {
    final cleanUsername = username.trim();
    final cleanPassword = password.trim();
    if (cleanUsername.isEmpty || cleanPassword.isEmpty) return null;

    try {
      // 1) Buscar el documento por username (sin que el usuario escriba email)
      final snapshot = await _firestore.users
          .where('username', isEqualTo: cleanUsername)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      final data = doc.data();
      final profile = UserModel.fromMap(data, doc.id);

      if (!profile.isActive) return null;

      // 2) Obtener email asociado en el documento
      final email = profile.email.trim();
      if (email.isEmpty) return null;

      // 3) Autenticar en FirebaseAuth con email/password
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: cleanPassword,
      );

      final user = credential.user;
      if (user == null) return null;

      // 4) Devolver perfil desde Firestore
      return profile;
    } on FirebaseAuthException {
      return null;
    } on FirebaseException {
      return null;
    }
  }

}

