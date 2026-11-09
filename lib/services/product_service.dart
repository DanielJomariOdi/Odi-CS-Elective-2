import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/item.dart';

class ProductPage {
  const ProductPage({required this.items, required this.totalCount});

  final List<Item> items;
  final int totalCount;
}

class ProductService {
  ProductService({this._client});

  final SupabaseClient? _client;
  SupabaseClient get _db => _client ?? Supabase.instance.client;

  Future<ProductPage> fetchPage({
    required int page,
    required double minPrice,
    required double maxPrice,
    int pageSize = 6,
  }) async {
    if (page < 1 || pageSize < 1) {
      throw ArgumentError('Page and pageSize must be positive.');
    }
    final start = (page - 1) * pageSize;
    final end = start + pageSize - 1;

    // Filtering, ordering, pagination and counting occur on Supabase.
    final response = await _db
        .from('products')
        .select('id, name, description, price')
        .gte('price', minPrice)
        .lte('price', maxPrice)
        .order('id', ascending: true)
        .range(start, end)
        .count(CountOption.exact);

    return ProductPage(
      items: List.unmodifiable(response.data.map((row) => Item.fromJson(row))),
      totalCount: response.count,
    );
  }

  Future<Item?> fetchById(String id) async {
    final row = await _db
        .from('products')
        .select('id, name, description, price')
        .eq('id', id)
        .maybeSingle();
    return row == null ? null : Item.fromJson(row);
  }
}
