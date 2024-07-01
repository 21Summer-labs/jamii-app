import 'package:flutter/material.dart';
import '../../controllers/store_controller.dart';
import '../../models/store_model.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditStoreModal extends StatefulWidget {
  final StoreModel store;

  EditStoreModal({required this.store});

  @override
  _EditStoreModalState createState() => _EditStoreModalState();
}

class _EditStoreModalState extends State<EditStoreModal> {
  final _formKey = GlobalKey<FormState>();
  late String phoneNumber;
  late Map<String, dynamic> availableHours;
  late double latitude;
  late double longitude;
  File? storeFrontPhoto;
  late String storeFrontPhotoUrl;

  @override
  void initState() {
    super.initState();
    phoneNumber = widget.store.phoneNumber;
    availableHours = Map<String, dynamic>.from(widget.store.availableHours);
    latitude = widget.store.location.latitude;
    longitude = widget.store.location.longitude;
    storeFrontPhotoUrl = widget.store.storeFrontPhotoUrl;
  }

  @override
  Widget build(BuildContext context) {
    final storeController = Provider.of<StoreController>(context);

    return Container(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: phoneNumber,
              decoration: InputDecoration(labelText: 'Phone Number'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a phone number';
                }
                return null;
              },
              onSaved: (value) => phoneNumber = value!,
            ),
            // Add fields for editing available hours here
            // You might want to create a custom widget for handling the Map<String, dynamic>
            TextFormField(
              initialValue: latitude.toString(),
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
              initialValue: longitude.toString(),
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
              child: Text('Update Store Front Photo'),
              onPressed: () async {
                // Implement image picker functionality
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Update Store'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final updatedStore = StoreModel(
                    id: widget.store.id,
                    phoneNumber: phoneNumber,
                    availableHours: availableHours,
                    location: GeoPoint(latitude, longitude),
                    ownerId: widget.store.ownerId,
                    storeFrontPhotoUrl: storeFrontPhotoUrl,
                  );
                  await storeController.updateStore(updatedStore);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}