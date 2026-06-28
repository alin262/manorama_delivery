import 'package:flutter/material.dart';
import '../models/shop.dart';

class ShopDetailScreen extends StatelessWidget {
  final Shop shop;
  final String type;
  const ShopDetailScreen({super.key, required this.shop, required this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(shop.name)),
      body: const Center(child: Text('Shop Detail - Coming Soon!')),
    );
  }
}