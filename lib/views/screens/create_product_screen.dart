import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/product_model.dart';

class CreateProductScreen extends StatefulWidget {
  @override
  _CreateProductScreenState createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  dynamic _productImage;
  dynamic _audioFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (kIsWeb) {
          _productImage = pickedFile;
        } else {
          _productImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _pickAudio() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (kIsWeb) {
          _audioFile = pickedFile;
        } else {
          _audioFile = File(pickedFile.path);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final productController = Provider.of<ProductController>(context);
    final userController = Provider.of<UserController>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Create Product')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Product Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a product name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Product Image'),
            ),
            if (_productImage != null) ...[
              SizedBox(height: 8),
              kIsWeb
                ? Image.network(_productImage.path)
                : Image.file(_productImage, height: 100),
            ],
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickAudio,
              child: Text('Pick Audio File'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate() && _productImage != null) {
                  final userId = userController.getCurrentUserId();
                  if (userId != null) {
                    final newProduct = ProductModel(
                      id: '',
                      storeId: userId,
                      name: _nameController.text,
                      imageUrl: '',
                      description: _descriptionController.text,
                      price: double.parse(_priceController.text),
                      audioUrl: null,
                    );
                    await productController.createProduct(newProduct, _productImage, audioFile: _audioFile);
                    Navigator.pop(context);
                  }
                }
              },
              child: Text('Create Product'),
            ),
          ],
        ),
      ),
    );
  }
}