import 'package:flutter/material.dart';

import '../models/item.dart';
import '../services/product_service.dart';

class ProductController extends ChangeNotifier {
  ProductController({ProductService? service})
    : _service = service ?? ProductService();

  static const int pageSize = 6;
  static const double lowerBound = 0;
  static const double upperBound = 1000;

  final ProductService _service;
  RangeValues _priceRange = const RangeValues(lowerBound, upperBound);
  List<Item> _items = const [];
  int _page = 1;
  int _totalCount = 0;
  int _requestVersion = 0;
  bool _loading = false;
  bool _disposed = false;
  String? _error;

  RangeValues get priceRange => _priceRange;
  List<Item> get items => _items;
  int get currentPage => _page;
  int get totalCount => _totalCount;
  int get totalPages =>
      _totalCount == 0 ? 1 : (_totalCount + pageSize - 1) ~/ pageSize;
  bool get canGoBack => !_loading && _page > 1;
  bool get canGoNext => !_loading && _page < totalPages;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> load() async {
    if (_disposed) return;
    final version = ++_requestVersion;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.fetchPage(
        page: _page,
        minPrice: _priceRange.start,
        maxPrice: _priceRange.end,
        pageSize: pageSize,
      );
      if (_disposed || version != _requestVersion) return;
      _items = result.items;
      _totalCount = result.totalCount;
    } catch (error) {
      if (_disposed || version != _requestVersion) return;
      _items = const [];
      _error = 'Could not load products: $error';
    } finally {
      if (!_disposed && version == _requestVersion) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> setPriceRange(RangeValues range) {
    if (range == _priceRange) return Future<void>.value();
    _priceRange = range;
    _page = 1;
    return load();
  }

  Future<void> nextPage() {
    if (!canGoNext) return Future<void>.value();
    _page += 1;
    return load();
  }

  Future<void> previousPage() {
    if (!canGoBack) return Future<void>.value();
    _page -= 1;
    return load();
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}
