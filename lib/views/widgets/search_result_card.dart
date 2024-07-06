import 'package:flutter/material.dart';

class SearchResultCard extends StatelessWidget {
  final Map<String, dynamic> product;

  SearchResultCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(product['imageUrl'], height: 100, width: 100),
            Text(product['name'], style: TextStyle(color: Colors.white)),
            Text('£${product['price']}', style: TextStyle(color: Colors.yellow)),
            if (product['rating'] != null)
              Row(
                children: [
                  Icon(Icons.star, color: Colors.yellow, size: 16),
                  Text('${product['rating']}', style: TextStyle(color: Colors.white)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}