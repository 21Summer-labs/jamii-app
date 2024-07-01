// lib/models/store_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class StoreModel {
  final String id;
  final String ownerId;
  final String phoneNumber;
  final String storeFrontPhotoUrl;
  final Map<String, dynamic> availableHours;
  final GeoPoint location;

  StoreModel({
    required this.id,
    required this.ownerId,
    required this.phoneNumber,
    required this.storeFrontPhotoUrl,
    required this.availableHours,
    required this.location,
  });

  factory StoreModel.fromMap(Map<String, dynamic> map, String id) {
    return StoreModel(
      id: id,
      ownerId: map['ownerId'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      storeFrontPhotoUrl: map['storeFrontPhotoUrl'] ?? '',
      availableHours: Map<String, dynamic>.from(map['availableHours'] ?? {}),
      location: map['location'] ?? const GeoPoint(0, 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'phoneNumber': phoneNumber,
      'storeFrontPhotoUrl': storeFrontPhotoUrl,
      'availableHours': availableHours,
      'location': location,
    };
  }
}