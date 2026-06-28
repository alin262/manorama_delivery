import 'package:flutter/material.dart';

class AddBookScreen extends StatelessWidget {
  const AddBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Book')),
      body: const Center(child: Text('Add Book - Coming Soon!')),
    );
  }
}