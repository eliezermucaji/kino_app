import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/kino_theme.dart';
import '../data/api.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../widgets/kino_app_widgets.dart';

class OrdersScreen extends StatefulWidget {
  final OrderStatus initialStatus;

  /// Seta de voltar. Por defeito faz pop; no shell volta à Home.
  final VoidCallback? onBack;

  const OrdersScreen({
    super.key,
    this.initialStatus = OrderStatus.completed,
    this.onBack,
  });

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  static const _tabs = [
    (OrderStatus.completed, 'Concluido'),
    (OrderStatus.processing, 'Processando'),
    (OrderStatus.cancelled, 'Cancelado'),
  ];

  late OrderStatus _status;
  late Future<List<Order>> _future;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
    _future = Api.orders.getOrders(_status);
  }

  void _select(OrderStatus s) {
    setState(() {
      _status = s;
      _future = Api.orders.getOrders(s);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 0, 0),
              child: KinoBackArrow(onTap: widget.onBack),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 8),
              child: Text(
                'Meus Pedidos',
                style: GoogleFonts.inter(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: KinoColors.panel,
                ),
              ),
            ),
            _tabBar(),
            const SizedBox(height: 2),
            Expanded(
              child: FutureBuilder<List<Order>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: KinoColors.panel),
                    );
                  }
                  if (snap.hasError) {
                    return KinoMessage(
                      'Não foi possível carregar os pedidos.',
                      onRetry: () => _select(_status),
                    );
                  }
                  final orders = snap.data!;
                  if (orders.isEmpty) {
                    return const KinoMessage('Sem pedidos aqui.');
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 2),
                    itemBuilder: (_, i) => _OrderCard(order: orders[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final (status, label) in _tabs)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _select(status),
              child: Container(
                padding: const EdgeInsets.fromLTRB(8, 2, 8, 6),
                decoration: BoxDecoration(
                  color: status == _status
                      ? KinoColors.panel
                      : Colors.transparent,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: status == _status
                        ? FontWeight.w800
                        : FontWeight.w500,
                    color: status == _status ? Colors.white : KinoColors.panel,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final white = GoogleFonts.inter(color: Colors.white);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: KinoColors.panel,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.storeName,
            style: white.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 100,
                  height: 92,
                  child: KinoImage(order.image),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: white.copyWith(fontSize: 14),
                    ),
                    Text(
                      formatKz(order.total),
                      style: white.copyWith(
                        fontSize: 34,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Quantidade:${order.quantity}',
                      style: white.copyWith(fontSize: 14),
                    ),
                    Text(
                      'Data: ${order.dateLabel}',
                      style: white.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
