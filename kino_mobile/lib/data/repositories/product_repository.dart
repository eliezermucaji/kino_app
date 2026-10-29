import '../../models/product.dart';

/// Contrato que o resto da app usa. Quando o backend estiver pronto,
/// cria uma `ApiProductRepository` (com http/dio) que implementa isto
/// e troca em `lib/data/api.dart`. As telas não mudam.
abstract class ProductRepository {
  Future<List<Product>> getProducts({String? query});
  Future<Product> getProduct(String id);
}

/// API fake: dados locais com um pequeno atraso para simular a rede.
class FakeProductRepository implements ProductRepository {
  static const _delay = Duration(milliseconds: 400);

  static const _store = 'Nadine Store';

  static const List<Product> _data = [
    Product(
      id: '1',
      name: 'Gelado de Múcua',
      description:
          'Gelado artesanal de múcua, cremoso e refrescante, feito com a '
          'fruta do embondeiro. Ideal para matar o calor!',
      storeName: _store,
      price: 50,
      available: true,
      images: ['assets/images/gelado_mucua.png'],
    ),
    Product(
      id: '2',
      name: 'Pastel Massa Terna',
      description:
          'Massa terna e macia, recheada com carne temperada ao ponto. '
          'Quentinho, saboroso e irresistível.',
      storeName: _store,
      price: 150,
      available: true,
      images: ['assets/images/pastel_massa_terna.png'],
    ),
    Product(
      id: '3',
      name: 'Chamuça de Peixe',
      description:
          'Massa fina e dourada, recheada com um delicioso e suculento '
          'recheio de peixe temperado à perfeição com especiarias e ervas '
          'frescas. O petisco crocante e irresistível que faltava no teu dia!',
      storeName: _store,
      price: 100,
      available: true,
      images: [
        'assets/images/chamuca_peixe_1.png',
        'assets/images/chamuca_peixe_2.png',
        'assets/images/chamuca_peixe_3.png',
        'assets/images/chamuca_peixe_4.png',
      ],
    ),
    Product(
      id: '4',
      name: 'Bolinho',
      description:
          'Bolinhos fritos e polvilhados com açúcar, fofos por dentro e '
          'crocantes por fora.',
      storeName: _store,
      price: 50,
      available: true,
      images: ['assets/images/bolinho.png'],
    ),
    Product(
      id: '5',
      name: 'Pão Doce',
      description: 'Pão doce macio, acabado de sair do forno.',
      storeName: _store,
      price: 80,
      available: true,
      images: ['assets/images/pao_doce.png'],
    ),
    Product(
      id: '6',
      name: 'Sumo Natural',
      description: 'Sumo natural de fruta da época, sem conservantes.',
      storeName: _store,
      price: 100,
      available: false,
      images: ['assets/images/sumo_natural.png'],
    ),
  ];

  @override
  Future<List<Product>> getProducts({String? query}) async {
    await Future.delayed(_delay);
    final q = (query ?? '').trim().toLowerCase();
    if (q.isEmpty) return _data;
    return _data.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  @override
  Future<Product> getProduct(String id) async {
    await Future.delayed(_delay);
    return _data.firstWhere((p) => p.id == id);
  }
}
