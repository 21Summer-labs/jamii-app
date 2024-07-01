import 'package:flutter/material.dart';
import '../controllers/store_controller.dart';

class DeleteStoreConfirmationModal extends StatelessWidget {
  final String storeId;
  final Function onStoreDeleted;

  const DeleteStoreConfirmationModal({
    Key? key,
    required this.storeId,
    required this.onStoreDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete Store'),
      content: Text('Are you sure you want to delete this store? This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final storeController = StoreController();
            await storeController.deleteStore(storeId);
            onStoreDeleted();
            Navigator.of(context).pop();
          },
          child: Text('Delete'),
          style: ElevatedButton.styleFrom(primary: Colors.red),
        ),
      ],
    );
  }
}
