import 'package:act_1/data/item_data.dart';
import 'package:act_1/models/item.dart';
import 'package:act_1/services/product_service.dart';

class FakeProductService extends ProductService {
  @override
  Future<ProductPage> fetchPage({
    required int page,
    required double minPrice,
    required double maxPrice,
    int pageSize = 6,
  }) async {
    final matches =
        items
            .where((item) => item.price >= minPrice && item.price <= maxPrice)
            .toList()
          ..sort((a, b) => a.id.compareTo(b.id));
    final start = (page - 1) * pageSize;
    final end = (start + pageSize).clamp(0, matches.length).toInt();
    final pageItems = start >= matches.length
        ? <Item>[]
        : matches.sublist(start, end);
    return ProductPage(items: pageItems, totalCount: matches.length);
  }

  @override
  Future<Item?> fetchById(String id) async {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }
}
