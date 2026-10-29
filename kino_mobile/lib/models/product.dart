/// Formata um valor em kwanzas: 1500 -> "1500 Kz".
String formatKz(int value) => '$value Kz';

class Product {
  final String id;
  final String name;
  final String description;
  final String storeName;

  /// Preço em kwanzas.
  final int price;
  final bool available;

  /// Caminhos de assets ("assets/images/x.png") ou URLs (http...).
  final List<String> images;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.storeName,
    required this.price,
    required this.available,
    required this.images,
  });

  String get coverImage => images.isEmpty ? '' : images.first;

  /// Contrato JSON combinado com o backend (ajustar aos nomes reais da API).
  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'].toString(),
        name: json['name'] as String,
        description: (json['description'] ?? '') as String,
        storeName: (json['store_name'] ?? '') as String,
        price: (json['price'] as num).toInt(),
        available: (json['available'] ?? true) as bool,
        images: List<String>.from(json['images'] ?? const []),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'store_name': storeName,
        'price': price,
        'available': available,
        'images': images,
      };
}
