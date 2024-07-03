// lib/views/screens/admin_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/user_controller.dart';
import '../../controllers/store_controller.dart';
import '../../controllers/product_controller.dart';
import '../../models/user_model.dart';
import '../../models/store_model.dart';
import '../../models/product_model.dart';

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Admin Dashboard'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Users'),
              Tab(text: 'Stores'),
              Tab(text: 'Products'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            UserSection(),
            StoreSection(),
            ProductSection(),
          ],
        ),
      ),
    );
  }
}

class UserSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);

    return StreamBuilder<List<UserModel>>(
      stream: userController.getAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data ?? [];

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              title: Text(user.name),
              subtitle: Text(user.email),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => userController.deleteUser(user.id),
              ),
            );
          },
        );
      },
    );
  }
}

class StoreSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final storeController = Provider.of<StoreController>(context);

    return StreamBuilder<List<StoreModel>>(
      stream: storeController.getAllStores(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final stores = snapshot.data ?? [];

        return ListView.builder(
          itemCount: stores.length,
          itemBuilder: (context, index) {
            final store = stores[index];
            return ListTile(
              title: Text('Store ${store.id}'),
              subtitle: Text('Owner ID: ${store.ownerId}'),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => storeController.deleteStore(store.id),
              ),
            );
          },
        );
      },
    );
  }
}

class ProductSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productController = Provider.of<ProductController>(context);

    return StreamBuilder<List<ProductModel>>(
      stream: productController.getAllProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data ?? [];

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ListTile(
              title: Text(product.name),
              subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => productController.deleteProduct(product.id),
              ),
            );
          },
        );
      },
    );
  }
}