class ProductModel {
  final String id;
  final String storeId;
  final String name;
  final String imageUrl;
  final String description;
  final double price;
  final String? audioUrl;
  final List<double>? embedding;

  ProductModel({
    required this.id,
    required this.storeId,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.price,
    this.audioUrl,
    this.embedding,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      storeId: map['storeId'] ?? '',
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      audioUrl: map['audioUrl'],
      embedding: map['embedding'] != null ? List<double>.from(map['embedding']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'storeId': storeId,
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
      'price': price,
      'audioUrl': audioUrl,
      'embedding': embedding,
    };
  }
}