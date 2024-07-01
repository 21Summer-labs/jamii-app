import 'package:flutter/material.dart';
import '../models/store_model.dart';

class StoreReadSection extends StatelessWidget {
  final StoreModel store;

  const StoreReadSection({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Store Details', style: Theme.of(context).textTheme.headline5),
          SizedBox(height: 16),
          Image.network(
            store.storeFrontPhotoUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 16),
          Text('Store ID: ${store.id}'),
          Text('Owner ID: ${store.ownerId}'),
          Text('Phone Number: ${store.phoneNumber}'),
          Text('Location: ${store.location.latitude}, ${store.location.longitude}'),
          SizedBox(height: 16),
          Text('Available Hours:', style: Theme.of(context).textTheme.subtitle1),
          ...store.availableHours.entries.map((entry) => 
            Text('${entry.key}: ${entry.value}')
          ).toList(),
        ],
      ),
    );
  }
}
