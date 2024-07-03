// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'controllers/user_controller.dart';
import 'controllers/store_controller.dart';
import 'controllers/product_controller.dart'; // Import ProductController
import 'views/screens/login_screen.dart';
import 'views/screens/main_screen.dart';
import 'models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserController>(create: (_) => UserController()),
        ChangeNotifierProvider<StoreController>(create: (_) => StoreController()),
        ChangeNotifierProvider<ProductController>(create: (_) => ProductController()), // Add ProductController
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Name',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StreamBuilder<UserModel?>(
        stream: Provider.of<UserController>(context, listen: false).userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final UserModel? user = snapshot.data;
            return user == null ? LoginScreen() : MainScreen();
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}
