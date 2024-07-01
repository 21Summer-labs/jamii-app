import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static Future<void> initializeApp() async {
    await Firebase.initializeApp();
  }

  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;

  // Firestore CRUD operations

  static Future<DocumentReference> addDocument(String collection, Map<String, dynamic> data) async {
    return await firestore.collection(collection).add(data);
  }

  static Future<void> updateDocument(String collection, String documentId, Map<String, dynamic> data) async {
    await firestore.collection(collection).doc(documentId).update(data);
  }

  static Future<void> deleteDocument(String collection, String documentId) async {
    await firestore.collection(collection).doc(documentId).delete();
  }

  static Stream<QuerySnapshot> getCollectionStream(String collection) {
    return firestore.collection(collection).snapshots();
  }

  static Future<DocumentSnapshot> getDocument(String collection, String documentId) async {
    return await firestore.collection(collection).doc(documentId).get();
  }

  // Firebase Storage operations

  static Future<String> uploadFile(String path, dynamic file) async {
    TaskSnapshot snapshot = await storage.ref(path).putFile(file);
    return await snapshot.ref.getDownloadURL();
  }

  static Future<void> deleteFile(String path) async {
    await storage.ref(path).delete();
  }
}