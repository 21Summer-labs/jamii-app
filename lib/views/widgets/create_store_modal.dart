import 'package:flutter/material.dart';
import '../../controllers/store_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/store_model.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateStoreModal extends StatefulWidget {
  @override
  _CreateStoreModalState createState() => _CreateStoreModalState();
}

class _CreateStoreModalState extends State<CreateStoreModal> {
  final _formKey = GlobalKey<FormState>();
  late String phoneNumber;
  Map<String, dynamic> availableHours = {};
  late double latitude;
  late double longitude;
  File? storeFrontPhoto;
  String storeFrontPhotoUrl = '';

  @override
  Widget build(BuildContext context) {
    final storeController = Provider.of<StoreController>(context);
    final userController = Provider.of<UserController>(context);

    return Container(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Phone Number'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a phone number';
                }
                return null;
              },
              onSaved: (value) => phoneNumber = value!,
            ),
            // Add fields for available hours here
            // You might want to create a custom widget for handling the Map<String, dynamic>
            TextFormField(
              decoration: InputDecoration(labelText: 'Latitude'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter latitude';
                }
                return null;
              },
              onSaved: (value) => latitude = double.parse(value!),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Longitude'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter longitude';
                }
                return null;
              },
              onSaved: (value) => longitude = double.parse(value!),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Select Store Front Photo'),
              onPressed: () async {
                // Implement image picker functionality
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Add Store'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  
                  String? userId = userController.getCurrentUserId();
                  
                  if (userId != null) {
                    final newStore = StoreModel(
                      id: '', // This will be set by Firebase
                      phoneNumber: phoneNumber,
                      availableHours: availableHours,
                      location: GeoPoint(latitude, longitude),
                      ownerId: userId,
                      storeFrontPhotoUrl: storeFrontPhotoUrl,
                    );
                    
                    // Check if storeFrontPhoto is null before passing it
                    if (storeFrontPhoto != null) {
                      await storeController.createStore(newStore, storeFrontPhoto!);
                      Navigator.pop(context);
                    } else {
                      // Handle case where no photo was selected
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select a store front photo.')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('You must be logged in to create a store.')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}