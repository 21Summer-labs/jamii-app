import 'package:flutter_test/flutter_test.dart';
import 'package:your_app_name/models/user_model.dart';
import 'package:your_app_name/models/store_model.dart';
import 'package:your_app_name/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('UserModel Tests', () {
    test('should create a UserModel instance from a map', () {
      final map = {'id': '1', 'name': 'John Doe', 'email': 'john@example.com'};
      final user = UserModel.fromMap(map);
      expect(user.id, '1');
      expect(user.name, 'John Doe');
      expect(user.email, 'john@example.com');
    });
  });

  group('StoreModel Tests', () {
    test('should create a StoreModel instance from a map', () {
      final map = {
        'ownerId': '1',
        'phoneNumber': '1234567890',
        'storeFrontPhotoUrl': 'http://example.com/photo.jpg',
        'availableHours': {'Monday': '9-5'},
        'location': GeoPoint(0, 0),
      };
      final store = StoreModel.fromMap(map, '1');
      expect(store.id, '1');
      expect(store.ownerId, '1');
      expect(store.phoneNumber, '1234567890');
    });
  });

  group('ProductModel Tests', () {
    test('should create a ProductModel instance from a map', () {
      final map = {
        'storeId': '1',
        'name': 'Test Product',
        'imageUrl': 'http://example.com/image.jpg',
        'description': 'A test product',
        'price': 9.99,
      };
      final product = ProductModel.fromMap(map, '1');
      expect(product.id, '1');
      expect(product.name, 'Test Product');
      expect(product.price, 9.99);
    });
  });
}