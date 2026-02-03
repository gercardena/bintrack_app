import 'package:flutter/material.dart';
import '../../auth/presentation/protected_page.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProtectedPage(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Products'),
        ),
        body: const Center(
          child: Text(
            'PRODUCTS – Usuario autenticado',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
