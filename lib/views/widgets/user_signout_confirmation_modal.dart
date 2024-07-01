import 'package:flutter/material.dart';
import '../controllers/user_controller.dart';

class SignOutConfirmationDialog extends StatelessWidget {
  final Function onSignedOut;

  const SignOutConfirmationDialog({Key? key, required this.onSignedOut}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Sign Out'),
      content: Text('Are you sure you want to sign out?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final userController = UserController();
            await userController.signOut();
            onSignedOut();
            Navigator.of(context).pop();
          },
          child: Text('Sign Out'),
          style: ElevatedButton.styleFrom(primary: Colors.red),
        ),
      ],
    );
  }
}
