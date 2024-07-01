// lib/services/product_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Create a new product
  Future<String> createProduct(ProductModel product, File imageFile, {File? audioFile}) async {
    try {
      // Upload the product image
      String imageUrl = await _uploadFile(imageFile, 'product_images/${product.storeId}');
      
      // Upload the audio file if provided
      String? audioUrl;
      if (audioFile != null) {
        audioUrl = await _uploadFile(audioFile, 'product_audio/${product.storeId}');
      }
      
      // Create a new document in Firestore
      DocumentReference docRef = await _firestore.collection('products').add({
        ...product.toMap(),
        'imageUrl': imageUrl,
        'audioUrl': audioUrl,
      });
      
      return docRef.id;
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  // Get a product by ID
  Future<ProductModel?> getProduct(String productId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Update a product
  Future<void> updateProduct(ProductModel product) async {
    try {
      await _firestore.collection('products').doc(product.id).update(product.toMap());
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  // Delete a product
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  // Get all products
  Stream<List<ProductModel>> getAllProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Get products by store ID
  Stream<List<ProductModel>> getProductsByStoreId(String storeId) {
    return _firestore
        .collection('products')
        .where('storeId', isEqualTo: storeId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Helper method to upload files to Firebase Storage
  Future<String> _uploadFile(File file, String path) async {
    try {
      TaskSnapshot snapshot = await _storage.ref(path).putFile(file);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }
}