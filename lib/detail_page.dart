import 'package:flutter/material.dart';
import 'main.dart'; // Ensure you import the main.dart file where Item is defined

class DetailPage extends StatelessWidget {
  final Item item;

  const DetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.headerValue),
      ),
      body: Center(
        child: Text(
          'Details of ${item.headerValue}\n\n${item.expandedValue}',
          style: const TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
