import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../controllers/product_controller.dart';
import '../widgets/product_overview_card.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final ProductController _productController = ProductController();
  List<ProductModel> _searchResults = [];
  String _searchQuery = '';

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    // In a real app, you'd implement a more sophisticated search mechanism
    _productController.getAllProducts().first.then((products) {
      setState(() {
        _searchResults = products.where((product) =>
          product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.description.toLowerCase().contains(query.toLowerCase())
        ).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Search products...',
            border: InputBorder.none,
          ),
          onChanged: _performSearch,
        ),
      ),
      body: _searchQuery.isEmpty
          ? Center(child: Text('Start searching for products'))
          : ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                return ProductOverviewCard(
                  product: _searchResults[index],
                  onTap: () {
                    // Navigate to product details page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductPage(product: _searchResults[index]),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
