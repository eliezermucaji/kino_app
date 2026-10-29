enum OrderStatus { completed, processing, cancelled }

class Order {
  final String id;
  final String storeName;
  final String productName;
  final String image;
  final int quantity;

  /// Total em kwanzas.
  final int total;
  final DateTime date;
  final OrderStatus status;

  const Order({
    required this.id,
    required this.storeName,
    required this.productName,
    required this.image,
    required this.quantity,
    required this.total,
    required this.date,
    required this.status,
  });

  String get dateLabel {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'].toString(),
        storeName: json['store_name'] as String,
        productName: json['product_name'] as String,
        image: (json['image'] ?? '') as String,
        quantity: (json['quantity'] as num).toInt(),
        total: (json['total'] as num).toInt(),
        date: DateTime.parse(json['date'] as String),
        status: OrderStatus.values.byName(json['status'] as String),
      );
}
