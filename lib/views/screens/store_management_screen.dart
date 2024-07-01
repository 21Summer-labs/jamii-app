import 'package:flutter/material.dart';
import '../widgets/styled_widgets.dart';
import '../../controllers/store_controller.dart';
import '../../models/store_model.dart';
import 'package:provider/provider.dart';
import '../widgets/create_store_modal.dart';
import '../widgets/edit_store_modal.dart';

class StoreManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final storeController = Provider.of<StoreController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Heading4Text('Manage Stores', uppercase: true),
      ),
      body: StreamBuilder<List<StoreModel>>(
        stream: storeController.getAllStores(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Paragraph1Text('No stores found'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final store = snapshot.data![index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Heading4Text(store.phoneNumber),
                  subtitle: Paragraph2Text(_formatAvailableHours(store.availableHours)),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _showEditStoreModal(context, store),
                  ),
                  onTap: () => _showStoreDetails(context, store),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showCreateStoreModal(context),
      ),
    );
  }

  void _showCreateStoreModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: CreateStoreModal(),
          ),
        );
      },
    );
  }

  void _showEditStoreModal(BuildContext context, StoreModel store) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: EditStoreModal(store: store),
          ),
        );
      },
    );
  }

  void _showStoreDetails(BuildContext context, StoreModel store) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Heading3Text(store.phoneNumber),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Paragraph1Text('Available Hours:'),
                Paragraph2Text(_formatAvailableHours(store.availableHours)),
                SizedBox(height: 8),
                Paragraph1Text('Location: ${store.location.latitude}, ${store.location.longitude}'),
                SizedBox(height: 8),
                Paragraph1Text('Owner ID: ${store.ownerId}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Edit'),
              onPressed: () {
                Navigator.of(context).pop();
                _showEditStoreModal(context, store);
              },
            ),
          ],
        );
      },
    );
  }

  String _formatAvailableHours(Map<dynamic, dynamic> availableHours) {
    List<String> formattedHours = [];
    availableHours.forEach((day, hours) {
      formattedHours.add('$day: $hours');
    });
    return formattedHours.join('\n');
  }
}