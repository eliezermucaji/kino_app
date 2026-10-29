import 'repositories/auth_repository.dart';
import 'repositories/order_repository.dart';
import 'repositories/product_repository.dart';

/// Único sítio onde se escolhe a implementação dos repositórios.
///
/// Hoje: API fake. Quando o backend estiver pronto, troca cada `Fake...`
/// pela implementação real (ex.: `ApiProductRepository(baseUrl)`).
class Api {
  static final ProductRepository products = FakeProductRepository();
  static final OrderRepository orders = FakeOrderRepository();
  static final AuthRepository auth = FakeAuthRepository();
}
