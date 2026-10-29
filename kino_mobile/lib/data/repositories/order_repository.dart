import '../../models/order.dart';
import '../../models/product.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrders(OrderStatus status);
  Future<Order> createOrder({required Product product, required int quantity});
}

/// API fake: guarda os pedidos em memória (perdem-se ao fechar a app).
class FakeOrderRepository implements OrderRepository {
  static const _delay = Duration(milliseconds: 400);

  final List<Order> _orders = [
    Order(
      id: 'o1',
      storeName: 'Nadine Store',
      productName: 'Pastel Massa Terna',
      image: 'assets/images/pastel_massa_terna.png',
      quantity: 10,
      total: 1500,
      date: DateTime(2026, 7, 2),
      status: OrderStatus.completed,
    ),
    Order(
      id: 'o2',
      storeName: 'Nadine Store',
      productName: 'Chamuça de Peixe',
      image: 'assets/images/chamuca_peixe_1.png',
      quantity: 5,
      total: 500,
      date: DateTime(2026, 7, 5),
      status: OrderStatus.completed,
    ),
    Order(
      id: 'o3',
      storeName: 'Nadine Store',
      productName: 'Bolinho',
      image: 'assets/images/bolinho.png',
      quantity: 20,
      total: 1000,
      date: DateTime(2026, 10, 28),
      status: OrderStatus.processing,
    ),
    Order(
      id: 'o4',
      storeName: 'Nadine Store',
      productName: 'Gelado de Múcua',
      image: 'assets/images/gelado_mucua.png',
      quantity: 4,
      total: 200,
      date: DateTime(2026, 6, 20),
      status: OrderStatus.cancelled,
    ),
  ];

  @override
  Future<List<Order>> getOrders(OrderStatus status) async {
    await Future.delayed(_delay);
    final list = _orders.where((o) => o.status == status).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  @override
  Future<Order> createOrder({
    required Product product,
    required int quantity,
  }) async {
    await Future.delayed(_delay);
    final order = Order(
      id: 'o${_orders.length + 1}',
      storeName: product.storeName,
      productName: product.name,
      image: product.coverImage,
      quantity: quantity,
      total: product.price * quantity,
      date: DateTime.now(),
      status: OrderStatus.processing,
    );
    _orders.add(order);
    return order;
  }
}
