import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/store_model.dart';
import '../controllers/store_controller.dart';

class UpdateStoreModal extends StatefulWidget {
  final StoreModel store;
  final Function(StoreModel) onStoreUpdated;

  const UpdateStoreModal({Key? key, required this.store, required this.onStoreUpdated}) : super(key: key);

  @override
  _UpdateStoreModalState createState() => _UpdateStoreModalState();
}

class _UpdateStoreModalState extends State<UpdateStoreModal> {
  final _formKey = GlobalKey<FormState>();
  final StoreController _storeController = StoreController();
  
  late String _phoneNumber;
  File? _storeFrontPhoto;
  late Map<String, dynamic> _availableHours;
  late double _latitude;
  late double _longitude;

  @override
  void initState() {
    super.initState();
    _phoneNumber = widget.store.phoneNumber;
    _availableHours = widget.store.availableHours;
    _latitude = widget.store.location.latitude;
    _longitude = widget.store.location.longitude;
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _storeFrontPhoto = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text('Update Store', style: Theme.of(context).textTheme.headline6),
              TextFormField(
                initialValue: _phoneNumber,
                decoration: InputDecoration(labelText: 'Phone Number'),
                onSaved: (value) => _phoneNumber = value ?? '',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a phone number' : null,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Change Store Front Photo'),
              ),
              if (_storeFrontPhoto != null) 
                Image.file(_storeFrontPhoto!, height: 100)
              else 
                Image.network(widget.store.storeFrontPhotoUrl, height: 100),
              SizedBox(height: 16),
              // Add fields for available hours and location
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    final updatedStore = StoreModel(
                      id: widget.store.id,
                      ownerId: widget.store.ownerId,
                      phoneNumber: _phoneNumber,
                      storeFrontPhotoUrl: widget.store.storeFrontPhotoUrl,
                      availableHours: _availableHours,
                      location: GeoPoint(_latitude, _longitude),
                    );
                    await _storeController.updateStore(updatedStore);
                    widget.onStoreUpdated(updatedStore);
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Update Store'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
