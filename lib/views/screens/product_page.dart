import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../controllers/store_controller.dart';
import '../models/store_model.dart';

class ProductPage extends StatefulWidget {
  final ProductModel product;

  const ProductPage({Key? key, required this.product}) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final StoreController _storeController = StoreController();
  late Future<StoreModel?> _storeFuture;

  @override
  void initState() {
    super.initState();
    _storeFuture = _storeController.getStore(widget.product.storeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.product.imageUrl,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '\$${widget.product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headline6?.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Description:',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  Text(widget.product.description),
                  if (widget.product.audioUrl != null) ...[
                    SizedBox(height: 16),
                    Text(
                      'Audio Description:',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    // Add an audio player widget here
                  ],
                  SizedBox(height: 24),
                  Text(
                    'Sold by:',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  FutureBuilder<StoreModel?>(
                    future: _storeFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (snapshot.hasData) {
                        final store = snapshot.data!;
                        return ListTile(
                          leading: Image.network(
                            store.storeFrontPhotoUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(store.phoneNumber),
                          subtitle: Text('Store ID: ${store.id}'),
                          onTap: () {
                            // Navigate to store details page
                          },
                        );
                      }
                      return Text('Store information not available');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
