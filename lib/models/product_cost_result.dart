import 'package:maliyet_app/models/recipe_details.dart';

class ProductCostResult {
  final String productName;
  final List<RecipeDetails> recipes;
  final double totalCost;
  final double salePrice;
  final bool hasRecipe;

  ProductCostResult({
    required this.productName,
    required this.recipes,
    required this.totalCost,
    required this.salePrice,
    required this.hasRecipe,
  });
}
