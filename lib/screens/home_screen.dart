import 'package:flutter/material.dart';
import 'package:maliyet_app/screens/calculation_screen.dart';
import 'package:maliyet_app/screens/material_screen.dart';
import 'package:maliyet_app/screens/product_screen.dart';
import 'package:maliyet_app/screens/recipe_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maliyet Hesabı')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MaterialScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.inventory_2),
              label: const Text('Hammaddeler'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.production_quantity_limits),
              label: const Text('Ürünler'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RecipeScreen()),
                );
              },
              icon: Icon(Icons.receipt_long),
              label: Text('Reçete'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CalculationScreen(),
                  ),
                );
              },
              icon: Icon(Icons.calculate_rounded),
              label: Text('Hesapla'),
            ),
          ],
        ),
      ),
    );
  }
}
