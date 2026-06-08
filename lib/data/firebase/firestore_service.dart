import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._();

  static final instance = FirestoreService._();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get users =>
      firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get students =>
      firestore.collection('students');

  CollectionReference<Map<String, dynamic>> get teachers =>
      firestore.collection('teachers');

  CollectionReference<Map<String, dynamic>> get groups =>
      firestore.collection('groups');

  CollectionReference<Map<String, dynamic>> get justifications =>
      firestore.collection('justifications');
}