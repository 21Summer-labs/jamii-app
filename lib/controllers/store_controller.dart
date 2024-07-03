// lib/controllers/store_controller.dart

// ignore: unused_import
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/store_model.dart';
import '../services/store_service.dart';

class StoreController extends ChangeNotifier {
  final StoreService _storeService = StoreService();

  Future<String> createStore(StoreModel store, dynamic storeFrontPhoto) async {
    try {
      return await _storeService.createStore(store, storeFrontPhoto);
    } catch (e) {
      print('Error creating store: $e');
      rethrow;
    }
  }

  Future<StoreModel?> getStore(String storeId) async {
    try {
      return await _storeService.getStore(storeId);
    } catch (e) {
      print('Error getting store: $e');
      rethrow;
    }
  }

  Future<void> updateStore(StoreModel store) async {
    try {
      await _storeService.updateStore(store);
    } catch (e) {
      print('Error updating store: $e');
      rethrow;
    }
  }

  Future<void> deleteStore(String storeId) async {
    try {
      await _storeService.deleteStore(storeId);
    } catch (e) {
      print('Error deleting store: $e');
      rethrow;
    }
  }

  Stream<List<StoreModel>> getAllStores() {
    return _storeService.getAllStores();
  }
}