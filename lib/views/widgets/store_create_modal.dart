import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/store_model.dart';
import '../controllers/store_controller.dart';

class CreateStoreModal extends StatefulWidget {
  final Function(StoreModel) onStoreCreated;

  const CreateStoreModal({Key? key, required this.onStoreCreated}) : super(key: key);

  @override
  _CreateStoreModalState createState() => _CreateStoreModalState();
}

class _CreateStoreModalState extends State<CreateStoreModal> {
  final _formKey = GlobalKey<FormState>();
  final StoreController _storeController = StoreController();
  
  String _phoneNumber = '';
  File? _storeFrontPhoto;
  Map<String, dynamic> _availableHours = {};
  double _latitude = 0;
  double _longitude = 0;

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
              Text('Create New Store', style: Theme.of(context).textTheme.headline6),
              TextFormField(
                decoration: InputDecoration(labelText: 'Phone Number'),
                onSaved: (value) => _phoneNumber = value ?? '',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a phone number' : null,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Store Front Photo'),
              ),
              if (_storeFrontPhoto != null) Image.file(_storeFrontPhoto!, height: 100),
              SizedBox(height: 16),
              // Add fields for available hours and location
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    final newStore = StoreModel(
                      id: '', // This will be set by Firebase
                      ownerId: '', // Set this to the current user's ID
                      phoneNumber: _phoneNumber,
                      storeFrontPhotoUrl: '', // This will be set after upload
                      availableHours: _availableHours,
                      location: GeoPoint(_latitude, _longitude),
                    );
                    final storeId = await _storeController.createStore(newStore, _storeFrontPhoto!);
                    newStore.id = storeId;
                    widget.onStoreCreated(newStore);
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Create Store'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
