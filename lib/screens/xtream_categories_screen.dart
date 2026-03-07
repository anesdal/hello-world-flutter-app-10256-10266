import 'package:flutter/material.dart';

class XtreamCategoriesScreen extends StatelessWidget {
  final String host;
  const XtreamCategoriesScreen({super.key, required this.host});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Categories")),
      body: Center(child: Text("Connected to: $host")),
    );
  }
}
