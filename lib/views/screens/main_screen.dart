// lib/views/screens/main_screen.dart

// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/user_controller.dart';
import '../../controllers/store_controller.dart';
import '../../controllers/product_controller.dart';
import '../../models/user_model.dart';
import '../../models/store_model.dart';
import '../../models/product_model.dart';
import 'search_screen.dart';
import 'admin_dashboard.dart';
import 'create_store_screen.dart';
import 'create_product_screen.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);
    final storeController = Provider.of<StoreController>(context);
    final productController = Provider.of<ProductController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminDashboard()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await userController.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserDetailsSection(),
              SizedBox(height: 16),
              StoreDetailsSection(),
              SizedBox(height: 16),
              ProductCatalogueSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.mic),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class UserDetailsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);
    final UserModel? user = userController.getCurrentUser();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User Details', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            Text('Name: ${user?.name ?? "N/A"}'),
            Text('Email: ${user?.email ?? "N/A"}'),
          ],
        ),
      ),
    );
  }
}

class StoreDetailsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);
    final storeController = Provider.of<StoreController>(context);
    final String? userId = userController.getCurrentUserId();

    return StreamBuilder<List<StoreModel>>(
      stream: storeController.getAllStores(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print('Error in StreamBuilder: ${snapshot.error}');
          return Text('Error: ${snapshot.error}');
        }

        final stores = snapshot.data ?? [];
        print('Number of stores: ${stores.length}');

        if (stores.isEmpty) {
          return Text('No stores found');
        }

        final userStore = stores.firstWhere(
          (store) => store.ownerId == userId,
          orElse: () => StoreModel(
            id: '',
            ownerId: '',
            phoneNumber: '',
            availableHours: [],
            storeFrontPhotoUrl: '',
            location: GeoPoint(0, 0),
          ),
        );

        print('User store ID: ${userStore.id}');
        print('Store front photo URL: ${userStore.storeFrontPhotoUrl}');

        if (userStore.id.isEmpty) {
          return ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateStoreScreen()),
              );
            },
            child: Text('Create Store'),
          );
        }

        return Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Store Details', style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 8),
                Text('Phone: ${userStore.phoneNumber}'),
                Text('Available Hours: ${userStore.availableHours}'),
                if (userStore.storeFrontPhotoUrl.isNotEmpty)
                  Image.network(
                    userStore.storeFrontPhotoUrl,
                    height: 100,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading image: $error');
                      print('Stack trace: $stackTrace');
                      return Column(
                        children: [
                          Icon(Icons.error),
                          Text('Failed to load image'),
                        ],
                      );
                    },
                  )
                else
                  Text('No store image available'),
              ],
            ),
          ),
        );
      },
    );
  }
}
class ProductCatalogueSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);
    final productController = Provider.of<ProductController>(context);
    final String? userId = userController.getCurrentUserId();

    return StreamBuilder<List<ProductModel>>(
      stream: productController.getAllProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final products = snapshot.data ?? [];
        final userProducts = products.where((product) => product.storeId == userId).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product Catalogue', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            if (userProducts.isEmpty)
              Text('No products yet.')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: userProducts.length,
                itemBuilder: (context, index) {
                  final product = userProducts[index];
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                    leading: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      width: 50,
                      height: 50,
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  );
                },
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateProductScreen()),
                );
              },
              child: Text('Add Product'),
            ),
          ],
        );
      },
    );
  }
}