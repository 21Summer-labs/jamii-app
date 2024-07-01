// lib/middleware/state_management.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';
import '../controllers/store_controller.dart';
import '../controllers/product_controller.dart';
import '../models/user_model.dart';

class AppState extends ChangeNotifier {
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  void setCurrentUser(UserModel? user) {
    _currentUser = user;
    notifyListeners();
  }
}

class StateManagementMiddleware extends StatelessWidget {
  final Widget child;

  StateManagementMiddleware({required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        Provider(create: (_) => UserController()),
        Provider(create: (_) => StoreController()),
        Provider(create: (_) => ProductController()),
      ],
      child: child,
    );
  }
}