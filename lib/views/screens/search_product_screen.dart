import 'package:flutter/material.dart';
import '../widgets/styled_widgets.dart';
import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';
import 'package:provider/provider.dart';

class SearchProductScreen extends StatefulWidget {
  @override
  _SearchProductScreenState createState() => _SearchProductScreenState();
}

class _SearchProductScreenState extends State<SearchProductScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductModel> _searchResults = [];

  @override
  Widget build(BuildContext context) {
    final productController = Provider.of<ProductController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Heading4Text('Search Products', uppercase: true),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for products...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    // Implement search functionality
                    // For now, we'll just get all products
                    setState(() {
                      _searchResults = [];
                    });
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ProductModel>>(
              stream: productController.getAllProducts(),
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
          ),
        ],
      ),
    );
  }
}