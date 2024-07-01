import 'package:flutter/material.dart';
import '../controllers/product_controller.dart';

class DeleteProductConfirmationModal extends StatelessWidget {
  final String productId;
  final Function onProductDeleted;

  const DeleteProductConfirmationModal({
    Key? key,
    required this.productId,
    required this.onProductDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete Product'),
      content: Text('Are you sure you want to delete this product? This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final productController = ProductController();
            await productController.deleteProduct(productId);
            onProductDeleted();
            Navigator.of(context).pop();
          },
          child: Text('Delete'),
          style: ElevatedButton.styleFrom(primary: Colors.red),
        ),
      ],
    );
  }
}
