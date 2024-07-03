// lib/views/screens/product_details_screen.dart

import 'package:flutter/material.dart';
import '../../models/product_model.dart';

class ProductDetailsScreen extends StatelessWidget {
  final ProductModel product;

  ProductDetailsScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(product.imageUrl),
              SizedBox(height: 16),
              Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
              SizedBox(height: 8),
              Text('\$${product.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 16),
              Text(product.description),
              if (product.audioUrl != null) ...[
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Implement audio playback
                  },
                  child: Text('Play Audio Description'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
