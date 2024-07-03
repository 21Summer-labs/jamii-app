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
import 'package:google_maps_flutter/google_maps_flutter.dart';

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



class StoreDetailsSection extends StatefulWidget {
  @override
  _StoreDetailsSectionState createState() => _StoreDetailsSectionState();
}

class _StoreDetailsSectionState extends State<StoreDetailsSection> {
  bool _showMap = true;

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
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => _showEditStoreModal(context, userStore),
                      child: Text('Edit Store'),
                    ),
                    ElevatedButton(
                      onPressed: () => _showDeleteConfirmation(context, userStore.id),
                      child: Text('Delete Store'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Store Location', style: Theme.of(context).textTheme.titleMedium),
                    IconButton(
                      icon: Icon(_showMap ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _showMap = !_showMap;
                        });
                      },
                    ),
                  ],
                ),
                if (_showMap)
                  Container(
                    height: 200,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(userStore.location.latitude, userStore.location.longitude),
                        zoom: 15,
                      ),
                      markers: {
                        Marker(
                          markerId: MarkerId('store_location'),
                          position: LatLng(userStore.location.latitude, userStore.location.longitude),
                        ),
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditStoreModal(BuildContext context, StoreModel store) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return EditStoreForm(store: store);
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, String storeId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Store'),
          content: Text('Are you sure you want to delete this store? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                // Call the delete method from your StoreController
                Provider.of<StoreController>(context, listen: false).deleteStore(storeId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class EditStoreForm extends StatefulWidget {
  final StoreModel store;

  EditStoreForm({required this.store});

  @override
  _EditStoreFormState createState() => _EditStoreFormState();
}

class _EditStoreFormState extends State<EditStoreForm> {
  late TextEditingController _phoneController;
  // Add more controllers for other fields

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.store.phoneNumber);
    // Initialize other controllers
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(labelText: 'Phone Number'),
          ),
          // Add more fields as needed
          SizedBox(height: 16),
          ElevatedButton(
            child: Text('Save Changes'),
            onPressed: () {
              // Update the store with new information
              final updatedStore = StoreModel(
                id: widget.store.id,
                ownerId: widget.store.ownerId,
                phoneNumber: _phoneController.text,
                availableHours: widget.store.availableHours,
                storeFrontPhotoUrl: widget.store.storeFrontPhotoUrl,
                location: widget.store.location,
              );
              Provider.of<StoreController>(context, listen: false).updateStore(updatedStore);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    // Dispose other controllers
    super.dispose();
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