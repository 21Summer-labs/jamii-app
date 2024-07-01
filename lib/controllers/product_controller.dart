// lib/controllers/product_controller.dart

import 'dart:io';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductController {
  final ProductService _productService = ProductService();

  Future<String> createProduct(ProductModel product, File imageFile, {File? audioFile}) async {
    try {
      return await _productService.createProduct(product, imageFile, audioFile: audioFile);
    } catch (e) {
      print('Error creating product: $e');
      rethrow;
    }
  }

  Future<ProductModel?> getProduct(String productId) async {
    try {
      return await _productService.getProduct(productId);
    } catch (e) {
      print('Error getting product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await _productService.updateProduct(product);
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _productService.deleteProduct(productId);
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }

  Stream<List<ProductModel>> getAllProducts() {
    return _productService.getAllProducts();
  }

  Stream<List<ProductModel>> getProductsByStoreId(String storeId) {
    return _productService.getProductsByStoreId(storeId);
  }
}