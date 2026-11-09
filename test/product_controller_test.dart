import 'package:act_1/state/product_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_product_service.dart';

void main() {
  test('Page 1 has six products; page 2 has three', () async {
    final controller = ProductController(service: FakeProductService());
    addTearDown(controller.dispose);
    await controller.load();
    expect(controller.items.length, 6);
    expect(controller.totalCount, 9);
    expect(controller.totalPages, 2);
    await controller.nextPage();
    expect(controller.currentPage, 2);
    expect(controller.items.length, 3);
  });

  test('Filtering is inclusive and resets page to one', () async {
    final controller = ProductController(service: FakeProductService());
    addTearDown(controller.dispose);
    await controller.load();
    await controller.nextPage();
    await controller.setPriceRange(const RangeValues(100, 400));
    expect(controller.currentPage, 1);
    expect(controller.totalCount, 3);
    expect(controller.items.map((item) => item.id).toList(), [
      'product-1',
      'product-5',
      'product-7',
    ]);
    expect(controller.totalPages, 1);
    expect(controller.canGoNext, false);
  });
}
