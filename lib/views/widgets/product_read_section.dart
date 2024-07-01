import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductReadSection extends StatelessWidget {
  final ProductModel product;

  const ProductReadSection({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Product Details', style: Theme.of(context).textTheme.headline5),
          SizedBox(height: 16),
          Image.network(
            product.imageUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 16),
          Text('Name: ${product.name}', style: Theme.of(context).textTheme.subtitle1),
          Text('Price: \$${product.price.toStringAsFixed(2)}'),
          SizedBox(height: 8),
          Text('Description:', style: Theme.of(context).textTheme.subtitle2),
          Text(product.description),
          if (product.audioUrl != null) ...[
            SizedBox(height: 16),
            Text('Audio Description:', style: Theme.of(context).textTheme.subtitle2),
            // Here you would add an audio player widget
          ],
        ],
      ),
    );
  }
}
