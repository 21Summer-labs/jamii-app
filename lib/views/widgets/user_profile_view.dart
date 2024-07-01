import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserProfileView extends StatelessWidget {
  final UserModel user;

  const UserProfileView({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('User Profile', style: Theme.of(context).textTheme.headline5),
          SizedBox(height: 16),
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              user.name[0].toUpperCase(),
              style: TextStyle(fontSize: 40, color: Colors.white),
            ),
          ),
          SizedBox(height: 16),
          Text('Name: ${user.name}', style: Theme.of(context).textTheme.subtitle1),
          SizedBox(height: 8),
          Text('Email: ${user.email}', style: Theme.of(context).textTheme.bodyText1),
          SizedBox(height: 8),
          Text('User ID: ${user.id}', style: Theme.of(context).textTheme.caption),
        ],
      ),
    );
  }
}
