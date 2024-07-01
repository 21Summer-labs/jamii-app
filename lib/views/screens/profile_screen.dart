import 'package:flutter/material.dart';
import '../widgets/styled_widgets.dart';
import '../../controllers/user_controller.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);
    final currentUser = userController.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: Heading4Text('Profile', uppercase: true),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (currentUser != null) ...[
              Heading2Text(currentUser.name),
              SizedBox(height: 8),
              Paragraph1Text(currentUser.email),
              SizedBox(height: 24),
              StyledButton(
                text: 'Sign Out',
                onPressed: () async {
                  await userController.signOut();
                  // Navigate to login screen or handle sign out
                },
              ),
            ] else ...[
              Paragraph1Text('Not signed in'),
              SizedBox(height: 24),
              StyledButton(
                text: 'Sign In',
                onPressed: () {
                  // Navigate to sign in screen
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}