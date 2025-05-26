import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/discount_repository.dart';

final discountRepositoryProvider = Provider((ref) {
  // Utilise la version singleton du repo
  return DiscountRepository.instance;
});
