import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'middleware/state_management.dart';
import 'middleware/session_management.dart';
import 'views/config/app_theme.dart';
import 'firebase_options.dart';
import 'views/screens/search_product_screen.dart';
import 'views/screens/store_management_screen.dart';
import 'views/screens/profile_screen.dart';
import 'views/screens/signup_screen.dart';
import 'views/screens/login_screen.dart';
import 'controllers/user_controller.dart';
import 'controllers/store_controller.dart';
import 'controllers/product_controller.dart';
import 'views/widgets/bottom_nav_bar.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class AppInitializer extends StatefulWidget {
  @override
  _AppInitializerState createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }

        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => UserController()),
        Provider(create: (_) => StoreController()),
        Provider(create: (_) => ProductController()),
      ],
      child: StateManagementMiddleware(
        child: SessionManagementMiddleware(
          child: MaterialApp(
            title: 'Your App Name',
            theme: AppTheme.theme,
            initialRoute: '/login',
            routes: {
              '/': (context) => MainNavigationScreen(),
              '/login': (context) => LoginScreen(),
              '/signup': (context) => SignupScreen(),
            },
          ),
        ),
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    SearchProductScreen(),
    StoreManagementScreen(),
    ProfileScreen(), // Ensure this screen is created
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
