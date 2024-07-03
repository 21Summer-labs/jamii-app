import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';
import 'product_details_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductModel> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final productController = Provider.of<ProductController>(context, listen: false);

    try {
      final results = await productController.searchProducts(_searchController.text);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });

      if (_searchResults.isEmpty) {
        setState(() {
          _errorMessage = 'No products found matching your search.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred while searching. Please try again.';
      });
    }
  }

  void _onMicPressed() {
    // Placeholder for speech-to-text functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Speech-to-text functionality not implemented yet.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Products')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: _performSearch,
                      ),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.mic),
                  onPressed: _onMicPressed,
                ),
              ],
            ),
          ),
          if (_isLoading)
            CircularProgressIndicator()
          else if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_errorMessage, style: TextStyle(color: Colors.red)),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final product = _searchResults[index];
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                    leading: Image.network(product.imageUrl, width: 50, height: 50),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsScreen(product: product),
                        ),
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