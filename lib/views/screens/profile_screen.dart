import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/store_model.dart';
import '../models/product_model.dart';
import '../controllers/user_controller.dart';
import '../controllers/store_controller.dart';
import '../controllers/product_controller.dart';
import '../widgets/user_profile_view.dart';
import '../widgets/store_overview_card.dart';
import '../widgets/product_overview_card.dart';
import '../widgets/edit_user_profile_modal.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserController _userController = UserController();
  final StoreController _storeController = StoreController();
  final ProductController _productController = ProductController();

  late Future<UserModel?> _userFuture;
  late Future<StoreModel?> _storeFuture;
  late Future<List<ProductModel>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _userController.getCurrentUser();
    _storeFuture = _fetchUserStore();
    _productsFuture = _fetchStoreProducts();
  }

  Future<StoreModel?> _fetchUserStore() async {
    final userId = _userController.getCurrentUserId();
    if (userId != null) {
      final stores = await _storeController.getAllStores().first;
      return stores.firstWhere((store) => store.ownerId == userId, orElse: () => null);
    }
    return null;
  }

  Future<List<ProductModel>> _fetchStoreProducts() async {
    final store = await _storeFuture;
    if (store != null) {
      return _productController.getProductsByStoreId(store.id).first;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<UserModel?>(
                future: _userFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasData) {
                    final user = snapshot.data!;
                    return Column(
                      children: [
                        UserProfileView(user: user),
                        ElevatedButton(
                          onPressed: () => _showEditProfileModal(context, user),
                          child: Text('Edit Profile'),
                        ),
                      ],
                    );
                  }
                  return Text('Failed to load user data');
                },
              ),
              SizedBox(height: 24),
              Text('Your Store', style: Theme.of(context).textTheme.headline6),
              FutureBuilder<StoreModel?>(
                future: _storeFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasData) {
                    return StoreOverviewCard(
                      store: snapshot.data!,
                      onTap: () {}, // Navigate to store details page
                    );
                  }
                  return Text('You don\'t have a store yet');
                },
              ),
              SizedBox(height: 24),
              Text('Your Products', style: Theme.of(context).textTheme.headline6),
              FutureBuilder<List<ProductModel>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasData) {
                    return Column(
                      children: snapshot.data!.map((product) => 
                        ProductOverviewCard(
                          product: product,
                          onTap: () {}, // Navigate to product details page
                        )
                      ).toList(),
                    );
                  }
                  return Text('No products found');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileModal(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => EditUserProfileModal(
        user: user,
        onProfileUpdated: (updatedUser) {
          setState(() {
            _userFuture = Future.value(updatedUser);
          });
        },
      ),
    );
  }
}
