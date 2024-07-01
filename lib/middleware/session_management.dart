// lib/middleware/session_management.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';
import 'state_management.dart';

class SessionManagementMiddleware extends StatefulWidget {
  final Widget child;

  SessionManagementMiddleware({required this.child});

  @override
  _SessionManagementMiddlewareState createState() => _SessionManagementMiddlewareState();
}

class _SessionManagementMiddlewareState extends State<SessionManagementMiddleware> {
  @override
  void initState() {
    super.initState();
    final userController = Provider.of<UserController>(context, listen: false);
    userController.userStream.listen((user) {
      Provider.of<AppState>(context, listen: false).setCurrentUser(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}