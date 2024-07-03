import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/store_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/store_model.dart';
import '../../services/gps_service.dart';

class CreateStoreScreen extends StatefulWidget {
  @override
  _CreateStoreScreenState createState() => _CreateStoreScreenState();
}

class _CreateStoreScreenState extends State<CreateStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  dynamic _storeFrontPhoto;
  List<Map<String, dynamic>> _availableHours = [];
  GeoPoint _location = GeoPoint(0, 0);
  final GPSService _gpsService = GPSService();

  @override
  void initState() {
    super.initState();
    _addAvailableHours(); // Add initial available hours
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (kIsWeb) {
          _storeFrontPhoto = pickedFile;
        } else {
          _storeFrontPhoto = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await _gpsService.getCurrentLocation();
      setState(() {
        _location = GeoPoint(position.latitude, position.longitude);
      });
      _showSnackBar('Location updated successfully');
    } catch (e) {
      _showSnackBar('Failed to get location: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _addAvailableHours() {
    setState(() {
      _availableHours.add({
        'days': [],
        'startTime': '${TimeOfDay.now().hour}:${TimeOfDay.now().minute}',
        'endTime': '${TimeOfDay.now().hour}:${TimeOfDay.now().minute}',
      });
    });
  }

  void _removeAvailableHours(int index) {
    setState(() {
      _availableHours.removeAt(index);
    });
  }

  Widget _buildAvailableHoursInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Available Hours', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        ..._availableHours.asMap().entries.map((entry) {
          int index = entry.key;
          return Card(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDaySelector(index),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildTimePicker(index, true)),
                      SizedBox(width: 16),
                      Expanded(child: _buildTimePicker(index, false)),
                    ],
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _removeAvailableHours(index),
                    child: Text('Remove'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: _addAvailableHours,
          child: Text('Add Available Hours'),
        ),
      ],
    );
  }

  Widget _buildDaySelector(int index) {
    List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Wrap(
      spacing: 8,
      children: days.map((day) {
        bool isSelected = _availableHours[index]['days'].contains(day);
        return FilterChip(
          label: Text(day),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _availableHours[index]['days'].add(day);
              } else {
                _availableHours[index]['days'].remove(day);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildTimePicker(int index, bool isStart) {
  String label = isStart ? 'Start Time' : 'End Time';
  String key = isStart ? 'startTime' : 'endTime';
  return InkWell(
    onTap: () async {
      TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: _availableHours[index][key] != null
            ? TimeOfDay(
                hour: int.parse(_availableHours[index][key].split(':')[0]),
                minute: int.parse(_availableHours[index][key].split(':')[1]),
              )
            : TimeOfDay.now(),
      );
      if (picked != null) {
        setState(() {
          _availableHours[index][key] = '${picked.hour}:${picked.minute}';
        });
      }
    },
    child: InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: Text(_availableHours[index][key] ?? 'Select time'),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final storeController = Provider.of<StoreController>(context);
    final userController = Provider.of<UserController>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Create Store')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a phone number';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Store Front Photo'),
            ),
            if (_storeFrontPhoto != null) ...[
              SizedBox(height: 8),
              kIsWeb
                ? Image.network(_storeFrontPhoto.path)
                : Image.file(_storeFrontPhoto, height: 100),
            ],
            SizedBox(height: 16),
            _buildAvailableHoursInput(),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _getCurrentLocation,
              child: Text('Get Current Location'),
            ),
            SizedBox(height: 16),
            Text('Latitude: ${_location.latitude}, Longitude: ${_location.longitude}'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate() && _storeFrontPhoto != null) {
                  final userId = userController.getCurrentUserId();
                  if (userId != null) {
                    // Convert TimeOfDay to String before creating StoreModel
                    List<Map<String, dynamic>> formattedHours = _availableHours.map((hours) {
                      return {
                        'days': hours['days'],
                        'startTime': '${hours['startTime'].hour}:${hours['startTime'].minute}',
                        'endTime': '${hours['endTime'].hour}:${hours['endTime'].minute}',
                      };
                    }).toList();

                    final newStore = StoreModel(
                      id: '',
                      ownerId: userId,
                      phoneNumber: _phoneController.text,
                      storeFrontPhotoUrl: '',
                      availableHours: _availableHours,
                      location: _location,
                    );
                    try {
                      await storeController.createStore(newStore, _storeFrontPhoto);
                      Navigator.pop(context);
                    } catch (e) {
                      _showSnackBar('Error creating store: $e');
                    }
                  }
                } else {
                  _showSnackBar('Please fill all fields and select a store front photo');
                }
              },
              child: Text('Create Store'),
            ),
          ],
        ),
      ),
    );
  }
}