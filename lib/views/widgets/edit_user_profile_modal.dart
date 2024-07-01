import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../controllers/user_controller.dart';

class EditUserProfileModal extends StatefulWidget {
  final UserModel user;
  final Function(UserModel) onProfileUpdated;

  const EditUserProfileModal({Key? key, required this.user, required this.onProfileUpdated}) : super(key: key);

  @override
  _EditUserProfileModalState createState() => _EditUserProfileModalState();
}

class _EditUserProfileModalState extends State<EditUserProfileModal> {
  final _formKey = GlobalKey<FormState>();
  final UserController _userController = UserController();
  
  late String _name;

  @override
  void initState() {
    super.initState();
    _name = widget.user.name;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Edit Profile', style: Theme.of(context).textTheme.headline6),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Name'),
                onSaved: (value) => _name = value ?? '',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a name' : null,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    await _userController.updateUserProfile(_name);
                    final updatedUser = UserModel(
                      id: widget.user.id,
                      name: _name,
                      email: widget.user.email,
                    );
                    widget.onProfileUpdated(updatedUser);
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
