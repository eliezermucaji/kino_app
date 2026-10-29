import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/kino_theme.dart';
import '../data/api.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../widgets/kino_app_widgets.dart';
import 'orders_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _pageController = PageController();
  int _page = 0;
  int _quantity = 1;
  bool _ordering = false;

  Product get _p => widget.product;
  int get _total => _p.price * _quantity;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextImage() {
    final next = (_page + 1) % _p.images.length;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _order() async {
    setState(() => _ordering = true);
    try {
      await Api.orders.createOrder(product: _p, quantity: _quantity);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido feito com sucesso!')),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              const OrdersScreen(initialStatus: OrderStatus.processing),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _ordering = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível fazer o pedido.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orange = GoogleFonts.inter(
      color: KinoColors.panel,
      fontWeight: FontWeight.w800,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 0, 4),
                child: const KinoBackArrow(),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                children: [
                  _gallery(),
                  if (_p.images.length > 1) _dots(),
                  const SizedBox(height: 12),
                  Text(
                    _p.name,
                    style: orange.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _p.price == 0 ? '' : formatKz(_p.price).toUpperCase(),
                    style: orange.copyWith(fontSize: 32, height: 1.0),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        _p.storeName,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.circle,
                        size: 12,
                        color: _p.available
                            ? const Color(0xFF1DB52A)
                            : Colors.grey,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _p.available ? 'Disponivel' : 'Indisponível',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _p.description,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      height: 1.25,
                      color: const Color(0xFF7A7A7A),
                    ),
                  ),
                  const SizedBox(height: 26),
                  _quantityAndTotal(orange),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: _orderButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gallery() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: AspectRatio(
        aspectRatio: 348 / 348,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _p.images.isEmpty ? 1 : _p.images.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, i) =>
                  KinoImage(_p.images.isEmpty ? '' : _p.images[i]),
            ),
            if (_p.images.length > 1)
              Positioned(
                right: 6,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _nextImage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: KinoColors.panel,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _dots() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < _p.images.length; i++)
            Container(
              width: 14,
              height: 14,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == _page
                    ? const Color(0xFF757575)
                    : const Color(0xFFCFCFCF),
              ),
            ),
        ],
      ),
    );
  }

  Widget _quantityAndTotal(TextStyle orange) {
    final label = GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quantidade', style: label),
            const SizedBox(height: 6),
            Row(
              children: [
                _roundButton(Icons.remove, () {
                  if (_quantity > 1) setState(() => _quantity--);
                }),
                SizedBox(
                  width: 40,
                  child: Text(
                    '$_quantity',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 18),
                  ),
                ),
                _roundButton(Icons.add, () => setState(() => _quantity++)),
              ],
            ),
          ],
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Total a Pagar', style: label),
            Text(
              formatKz(_total).toUpperCase(),
              style: orange.copyWith(fontSize: 40, height: 1.1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _roundButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: KinoColors.panel,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x55F08200),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }

  Widget _orderButton() {
    final enabled = _p.available && !_ordering;
    return SizedBox(
      width: 280,
      height: 70,
      child: ElevatedButton(
        onPressed: enabled ? _order : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: KinoColors.redDark,
          disabledBackgroundColor: const Color(0xFFB9B2A0),
          foregroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: _ordering
            ? const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Text(
                'ORDER NOW',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
