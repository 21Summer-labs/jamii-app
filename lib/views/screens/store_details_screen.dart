import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/styled_widgets.dart';
import '../../controllers/store_controller.dart';
import '../../models/store_model.dart';
import '../widgets/edit_store_modal.dart';

class StoreDetailsScreen extends StatelessWidget {
  final String storeId;

  StoreDetailsScreen({required this.storeId});

  @override
  Widget build(BuildContext context) {
    final storeController = Provider.of<StoreController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Heading4Text('Store Details', uppercase: true),
      ),
      body: FutureBuilder<StoreModel?>(
        future: storeController.getStore(storeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Paragraph1Text('Store not found'));
          }
          final store = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Heading2Text('Phone: ${store.phoneNumber}'),
                SizedBox(height: 16),
                Heading3Text('Available Hours:'),
                Paragraph1Text(store.availableHours.toString()),
                SizedBox(height: 16),
                Heading3Text('Location:'),
                Paragraph1Text('${store.location.latitude}, ${store.location.longitude}'),
                SizedBox(height: 32),
                StyledButton(
                  text: 'View Products',
                  onPressed: () {
                    Navigator.pushNamed(context, '/product_management', arguments: storeId);
                  },
                ),
                SizedBox(height: 16),
                StyledButton(
                  text: 'Edit Store',
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => EditStoreModal(store: store),
                    );
                  },
                ),
                SizedBox(height: 16),
                StyledButton(
                  text: 'Delete Store',
                  onPressed: () async {
                    await storeController.deleteStore(storeId);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
