import 'package:flutter/material.dart';
import '../widgets/styled_widgets.dart';
import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';
import 'package:provider/provider.dart';

class ProductManagementScreen extends StatelessWidget {
  final String storeId;

  ProductManagementScreen({required this.storeId});

  @override
  Widget build(BuildContext context) {
    final productController = Provider.of<ProductController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Heading4Text('Manage Products', uppercase: true),
      ),
      body: StreamBuilder<List<ProductModel>>(
        stream: productController.getProductsByStoreId(storeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Paragraph1Text('No products found'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final product = snapshot.data![index];
              return ListTile(
                title: Heading4Text(product.name),
                subtitle: Paragraph2Text('\$${product.price.toStringAsFixed(2)}'),
                onTap: () {
                  Navigator.pushNamed(context, '/product_details', arguments: product.id);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Navigate to create product screen
          // For MVP, we'll just print a message
          print('Navigate to create product screen');
        },
      ),
    );
  }
}