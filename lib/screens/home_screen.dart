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
      appBar: AppBar(title: const Text("Maliyet Hesabı")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              "Hoş Geldiniz",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A3A5C),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Maliyet ve satış fiyatlarınızı kolayca hesaplayın",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: GridView.count(
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                crossAxisCount: 2,
                children: [
                  _menuCard(
                    context,
                    icon: Icons.inventory_2,
                    label: "Hammaddeler",
                    screen: const MaterialScreen(),
                  ),
                  _menuCard(
                    context,
                    icon: Icons.production_quantity_limits,
                    label: "Ürünler",
                    screen: const ProductScreen(),
                  ),
                  _menuCard(
                    context,
                    icon: Icons.receipt_long,
                    label: "Reçete",
                    screen: const RecipeScreen(),
                  ),
                  _menuCard(
                    context,
                    icon: Icons.calculate_rounded,
                    label: "Hesapla",
                    screen: const CalculationScreen(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Widget screen,
  }) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A3A5C).withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: const Color(0xFF1A3A5C)),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C2733),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
