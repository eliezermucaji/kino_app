import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/auth_controller.dart';
import '../core/kino_theme.dart';
import '../data/api.dart';
import '../models/product.dart';
import '../widgets/kino_app_widgets.dart';
import 'product_detail_screen.dart';

/// Abre o detalhe do produto; se não houver sessão, vai primeiro ao login.
Future<void> openProduct(BuildContext context, Product product) async {
  if (!await requireLogin(context)) return;
  if (!context.mounted) return;
  await Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
  );
}

class HomeScreen extends StatefulWidget {
  /// Chamado ao tocar na caixa de pesquisa (o shell muda para a aba Pesquisar).
  final VoidCallback? onSearchTap;

  const HomeScreen({super.key, this.onSearchTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Product>> _future;

  @override
  void initState() {
    super.initState();
    _future = Api.products.getProducts();
  }

  void _reload() => setState(() => _future = Api.products.getProducts());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              height: 52,
              child: Image.asset(
                'assets/images/kino_logo.png',
                errorBuilder: (_, __, ___) => Text(
                  'Kino',
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: KinoColors.panel,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _searchBox()),
              const SizedBox(width: 12),
              const Icon(
                Icons.notifications_none,
                color: KinoColors.panel,
                size: 36,
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 368 / 168,
              child: const KinoImage('assets/images/banner.png'),
            ),
          ),
          const SizedBox(height: 18),
          FutureBuilder<List<Product>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: CircularProgressIndicator(color: KinoColors.panel),
                  ),
                );
              }
              if (snap.hasError) {
                return SizedBox(
                  height: 160,
                  child: KinoMessage(
                    'Não foi possível carregar os produtos.',
                    onRetry: _reload,
                  ),
                );
              }
              final products = snap.data!;
              if (products.isEmpty) {
                return const SizedBox(
                  height: 160,
                  child: KinoMessage('Ainda não há produtos.'),
                );
              }
              return ProductGrid(products: products);
            },
          ),
        ],
      ),
    );
  }

  Widget _searchBox() {
    return GestureDetector(
      onTap: widget.onSearchTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: KinoColors.panel,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.white, size: 28),
            const SizedBox(width: 8),
            Text(
              'Pesquisa o teu Kino',
              style: GoogleFonts.inter(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grelha de 2 colunas com os cartões de produto.
class ProductGrid extends StatelessWidget {
  final List<Product> products;
  const ProductGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.98,
      ),
      itemBuilder: (context, i) => ProductCard(
        product: products[i],
        onTap: () => openProduct(context, products[i]),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: KinoImage(product.coverImage),
              ),
            ),
            Container(
              width: double.infinity,
              color: KinoColors.panel,
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatKz(product.price),
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
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
