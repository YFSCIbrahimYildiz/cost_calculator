import 'package:maliyet_app/models/product.dart';
import 'package:maliyet_app/models/raw_material.dart';
import 'package:maliyet_app/models/recipe.dart';

class CostCalculator {
  double calculateMaterialCost(RawMaterial material, Recipe recipe) {
    final unitPrice = material.purchasePrice / material.purchaseQuantity;

    final cost = unitPrice * recipe.quantity * (1 + recipe.lossRate / 100);
    return cost;
  }

  //toplam maliyet

  double calculateTotalCost(
    List<RawMaterial> materials,
    List<Recipe> recipes,
    Product product,
    
  ) {
    double total = 0;
    for (var recipe in recipes) {
      final matches = materials.where((m) => m.id == recipe.materialId);
      if (matches.isEmpty) {
        throw Exception(
          '${product.name} ürünün reçetesinde bulunamayan hammadde var (id: ${recipe.materialId})',
        );
      }
      final material = matches.first;
      final cost = calculateMaterialCost(material, recipe);
      total += cost;
    }
    return total;
  }

  double calculateSalePrice(
    List<RawMaterial> materials,
    List<Recipe> recipes,
    Product product,
  ) {
    double salePrice;
    final totalCost = calculateTotalCost(materials, recipes, product);
    salePrice = totalCost * (1 + product.profitMargin / 100);
    return salePrice;
  }
}