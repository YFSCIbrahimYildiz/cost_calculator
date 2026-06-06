import 'package:maliyet_app/models/recipe_details.dart';

class ProductWithRecipes {
  final int productId;
  final String productName;
  final List<RecipeDetails> recipes;

  ProductWithRecipes({
    required this.productId,
    required this.productName,
    required this.recipes,
  });
}
