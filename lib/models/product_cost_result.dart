import 'package:maliyet_app/models/material_cost_line.dart';

class ProductCostResult {
  final String productName;
  final List<MaterialCostLine> recipes;
  final double totalCost;
  final double salePrice;
  final double profitMargin;
  final bool hasRecipe;

  ProductCostResult({
    required this.productName,
    required this.recipes,
    required this.totalCost,
    required this.salePrice,
    required this.profitMargin,
    required this.hasRecipe,
  });
}
