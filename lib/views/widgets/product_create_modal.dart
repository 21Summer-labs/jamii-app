import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/product_model.dart';
import '../controllers/product_controller.dart';

class CreateProductModal extends StatefulWidget {
  final String storeId;
  final Function(ProductModel) onProductCreated;

  const CreateProductModal({Key? key, required this.storeId, required this.onProductCreated}) : super(key: key);

  @override
  _CreateProductModalState createState() => _CreateProductModalState();
}

class _CreateProductModalState extends State<CreateProductModal> {
  final _formKey = GlobalKey<FormState>();
  final ProductController _productController = ProductController();
  
  String _name = '';
  String _description = '';
  double _price = 0;
  File? _imageFile;
  File? _audioFile;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickAudio() async {
    // Implement audio picking logic here
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
              Text('Create New Product', style: Theme.of(context).textTheme.headline6),
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                onSaved: (value) => _name = value ?? '',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a name' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (value) => _description = value ?? '',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a description' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _price = double.tryParse(value ?? '') ?? 0,
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a price' : null,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Product Image'),
              ),
              if (_imageFile != null) Image.file(_imageFile!, height: 100),
              SizedBox(height: 16),
              
              ElevatedButton(
              onPressed: _pickAudio,
              child: Text('Pick Audio Description (Optional)'),
            ),
            if (_audioFile != null) Text('Audio file selected: ${_audioFile!.path}'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  _formKey.currentState?.save();
                  final newProduct = ProductModel(
                    id: '', // This will be set by Firebase
                    storeId: widget.storeId,
                    name: _name,
                    imageUrl: '', // This will be set after upload
                    description: _description,
                    price: _price,
                    audioUrl: null, // This will be set after upload if audio is provided
                  );
                  final productId = await _productController.createProduct(
                    newProduct, 
                    _imageFile!, 
                    audioFile: _audioFile
                  );
                  newProduct.id = productId;
                  widget.onProductCreated(newProduct);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Create Product'),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
