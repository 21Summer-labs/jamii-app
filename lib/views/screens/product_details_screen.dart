import 'package:flutter/material.dart';
import '../widgets/styled_widgets.dart';
import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';
import 'package:provider/provider.dart';

class ProductDetailsScreen extends StatelessWidget {
  final String productId;

  ProductDetailsScreen({required this.productId});

  @override
  Widget build(BuildContext context) {
    final productController = Provider.of<ProductController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Heading4Text('Product Details', uppercase: true),
      ),
      body: FutureBuilder<ProductModel?>(
        future: productController.getProduct(productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Paragraph1Text('Product not found'));
          }
          final product = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(product.imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
                SizedBox(height: 16),
                Heading2Text(product.name),
                SizedBox(height: 8),
                Heading3Text('\$${product.price.toStringAsFixed(2)}'),
                SizedBox(height: 16),
                Paragraph1Text(product.description),
                if (product.audioUrl != null) ...[
                  SizedBox(height: 16),
                  StyledButton(
                    text: 'Play Audio Description',
                    onPressed: () {
                      // Implement audio playback
                      print('Play audio: ${product.audioUrl}');
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}