import 'package:flutter/material.dart';
import '../models/store_model.dart';

class StoreOverviewCard extends StatelessWidget {
  final StoreModel store;
  final VoidCallback onTap;

  const StoreOverviewCard({Key? key, required this.store, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(
                store.storeFrontPhotoUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Store ID: ${store.id}',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Phone: ${store.phoneNumber}',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Location: ${store.location.latitude}, ${store.location.longitude}',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
