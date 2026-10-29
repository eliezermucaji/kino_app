import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/kino_theme.dart';
import '../data/api.dart';
import '../models/product.dart';
import '../widgets/kino_app_widgets.dart';
import 'home_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  late Future<List<Product>> _future;

  @override
  void initState() {
    super.initState();
    _future = Api.products.getProducts();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      setState(() => _future = Api.products.getProducts(query: text));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: KinoColors.panel,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.white, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onChanged: _onChanged,
                      cursorColor: Colors.white,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Pesquisa o teu Kino',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 18,
                          color: const Color(0xCCFFFFFF),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(color: KinoColors.panel),
                  );
                }
                if (snap.hasError) {
                  return KinoMessage(
                    'Não foi possível pesquisar.',
                    onRetry: () => _onChanged(_controller.text),
                  );
                }
                final list = snap.data!;
                if (list.isEmpty) {
                  return const KinoMessage('Nenhum produto encontrado.');
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                  children: [ProductGrid(products: list)],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
