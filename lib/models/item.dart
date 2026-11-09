import 'package:flutter/material.dart';

class Item {
  final String id;
  final String name;
  final String description;
  final double price;
  final IconData icon;

  const Item({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final rawPrice = json['price'];
    final price = rawPrice is num
        ? rawPrice.toDouble()
        : double.parse(rawPrice.toString());

    return Item(
      id: id,
      name: json['name'] as String,
      description: json['description'] as String,
      price: price,
      icon: switch (id) {
        'product-1' => Icons.phone_iphone_rounded,
        'product-2' => Icons.tablet_mac_rounded,
        'product-3' => Icons.laptop_mac_rounded,
        'product-4' => Icons.headphones_rounded,
        'product-5' => Icons.watch_rounded,
        'product-6' => Icons.photo_camera_rounded,
        'product-7' => Icons.sports_esports_rounded,
        'product-8' => Icons.speaker_rounded,
        'product-9' => Icons.speaker_rounded,
        _ => Icons.inventory_2_outlined,
      },
    );
  }
}
