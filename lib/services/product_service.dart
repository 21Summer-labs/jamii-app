import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:math' show sqrt;  
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/product_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GenerativeModel _model = GenerativeModel(
    model: 'embedding-001',
    apiKey: 'AIzaSyDOdl-PmkDKxdm4gZKrhU2dKmoIDsYylwA',
  );

  Future<List<double>> generateEmbedding(String text) async {
    try {
      final content = Content.text(text);
      final result = await _model.embedContent(content);
      return result.embedding.values.toList();
    } catch (e) {
      print('Error generating embedding: $e');
      return [];
    }
  }

  Future<String> createProduct(ProductModel product, dynamic imageFile, {dynamic audioFile}) async {
    try {
      // Upload the product image
      String imageUrl = await _uploadFile(imageFile, 'product_images/${product.storeId}');
      
      // Upload the audio file if provided
      String? audioUrl;
      if (audioFile != null) {
        audioUrl = await _uploadFile(audioFile, 'product_audio/${product.storeId}');
      }
      
      // Generate embedding for the product description
      List<double> embedding = await generateEmbedding(product.description);

      // Create a new document in Firestore
      DocumentReference docRef = await _firestore.collection('products').add({
        ...product.toMap(),
        'imageUrl': imageUrl,
        'audioUrl': audioUrl,
        'embedding': embedding,
      });
      
      return docRef.id;
    } catch (e) {
      print('Error creating product: $e');
      rethrow;
    }
  }

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

  Future<void> updateProduct(ProductModel product) async {
    try {
      await _firestore.collection('products').doc(product.id).update(product.toMap());
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  Stream<List<ProductModel>> getAllProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Stream<List<ProductModel>> getProductsByStoreId(String storeId) {
    return _firestore
        .collection('products')
        .where('storeId', isEqualTo: storeId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<List<ProductModel>> searchProductsByVector(String query, {int limit = 5}) async {
    try {
      // Generate embedding for the search query
      List<double> queryEmbedding = await generateEmbedding(query);

      // Fetch all products
      QuerySnapshot querySnapshot = await _firestore.collection('products').get();

      // Calculate cosine similarity and sort products
      List<ProductModel> allProducts = querySnapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      allProducts.sort((a, b) {
        double similarityA = cosineSimilarity(queryEmbedding, a.embedding ?? []);
        double similarityB = cosineSimilarity(queryEmbedding, b.embedding ?? []);
        return similarityB.compareTo(similarityA);
      });

      // Return top 'limit' results
      return allProducts.take(limit).toList();
    } catch (e) {
      print('Error searching products: $e');
      rethrow;
    }
  }

  
  double cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return 0;
    double dotProduct = 0;
    double normA = 0;
    double normB = 0;
    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  Future<String> _uploadFile(dynamic file, String path) async {
    try {
      late UploadTask uploadTask;

      if (kIsWeb) {
        // Handle web
        if (file is XFile) {
          uploadTask = _storage.ref(path).putData(
            await file.readAsBytes(),
            SettableMetadata(contentType: 'image/jpeg'),
          );
        } else {
          throw Exception('Unsupported file type for web');
        }
      } else {
        // Handle mobile
        if (file is File) {
          uploadTask = _storage.ref(path).putFile(file);
        } else if (file is XFile) {
          uploadTask = _storage.ref(path).putFile(File(file.path));
        } else {
          throw Exception('Unsupported file type for mobile');
        }
      }

      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }
}