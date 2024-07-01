import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/product_model.dart';
import '../controllers/product_controller.dart';

class UpdateProductModal extends StatefulWidget {
  final ProductModel product;
  final Function(ProductModel) onProductUpdated;

  const UpdateProductModal({Key? key, required this.product, required this.onProductUpdated}) : super(key: key);

  @override
  _UpdateProductModalState createState() => _UpdateProductModalState();
}

class _UpdateProductModalState extends State<UpdateProductModal> {
  final _formKey = GlobalKey<FormState>();
  final ProductController _productController = ProductController();
  
  late String _name;
  late String _description;
  late double _price;
  File? _imageFile;
  File? _audioFile;

  @override
  void initState() {
    super.initState();
    _name = widget.product.name;
    _description = widget.product.description;
    _price = widget.product.price;
  }

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
              Text('Update Product', style: Theme.of(context).textTheme.headline6),
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Name'),
                onSaved: (value) => _name = value ?? '',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a name' : null,
              ),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (value) => _description = value ?? '',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a description' : null,
              ),
              TextFormField(
                initialValue: _price.toString(),
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _price = double.tryParse(value ?? '') ?? 0,
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a price' : null,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Change Product Image'),
              ),
              if (_imageFile != null) 
                Image.file(_imageFile!, height: 100)
              else 
                Image.network(widget.product.imageUrl, height: 100),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickAudio,
                child: Text('Change Audio Description (Optional)'),
              ),
              if (_audioFile != null) 
                Text('New audio file selected: ${_audioFile!.path}')
              else if (widget.product.audioUrl != null)
                Text('Current audio: ${widget.product.audioUrl}'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    final updatedProduct = ProductModel(
                      id: widget.product.id,
                      storeId: widget.product.storeId,
                      name: _name,
                      imageUrl: widget.product.imageUrl,
                      description: _description,
                      price: _price,
                      audioUrl: widget.product.audioUrl,
                    );
                    await _productController.updateProduct(updatedProduct);
                    widget.onProductUpdated(updatedProduct);
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Update Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
