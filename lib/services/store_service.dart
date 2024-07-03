// lib/services/store_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/store_model.dart';

class StoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Create a new store
  Future<String> createStore(StoreModel store, dynamic storeFrontPhoto) async {
    try {
      // Upload the store front photo
      String photoUrl = await _uploadFile(storeFrontPhoto, 'store_photos/${store.ownerId}');
      
      // Create a new document in Firestore
      DocumentReference docRef = await _firestore.collection('stores').add({
        ...store.toMap(),
        'storeFrontPhotoUrl': photoUrl,
      });
      
      return docRef.id;
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  // Get a store by ID
  Future<StoreModel?> getStore(String storeId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('stores').doc(storeId).get();
      if (doc.exists) {
        return StoreModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Update a store
  Future<void> updateStore(StoreModel store) async {
    try {
      await _firestore.collection('stores').doc(store.id).update(store.toMap());
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  // Delete a store
  Future<void> deleteStore(String storeId) async {
    try {
      await _firestore.collection('stores').doc(storeId).delete();
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  // Get all stores
  Stream<List<StoreModel>> getAllStores() {
    return _firestore.collection('stores').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => StoreModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Helper method to upload files to Firebase Storage
  Future<String> _uploadFile(dynamic file, String path) async {
    try {
      if (kIsWeb) {
        // Handle web file upload
        TaskSnapshot snapshot = await _storage.ref(path).putData(
          await file.readAsBytes(),
          SettableMetadata(contentType: 'image/jpeg'),
        );
        return await snapshot.ref.getDownloadURL();
      } else {
        // Handle mobile file upload
        TaskSnapshot snapshot = await _storage.ref(path).putFile(file as File);
        return await snapshot.ref.getDownloadURL();
      }
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }
}