import 'package:flutter/material.dart';
import 'package:maliyet_app/database/database_helper.dart';
import 'package:maliyet_app/models/product.dart';
import 'package:maliyet_app/models/product_cost_result.dart';
import 'package:maliyet_app/models/raw_material.dart';
import 'package:maliyet_app/models/recipe.dart';
import 'package:maliyet_app/models/recipe_details.dart';
import 'package:maliyet_app/services/cost_calculator.dart';

class CalculationScreen extends StatefulWidget {
  const CalculationScreen({super.key});

  @override
  State<CalculationScreen> createState() => _CalculationScreenState();
}

class _CalculationScreenState extends State<CalculationScreen> {
  final calculator = CostCalculator();
  final dbHelper = DatabaseHelper.instance;
  List<ProductCostResult> result = [];
  String searchQuery = "";
  bool showOnlyNoRecipe = false;
  @override
  void initState() {
    super.initState();
    _loadAndCalculate();
  }

  @override
  Widget build(BuildContext context) {
    final calculatedNumber = result.where((item) => item.hasRecipe).length;

    final filteredResults = result.where((item) {
      final recipeFilter = showOnlyNoRecipe ? !item.hasRecipe : true;
      final searchFilter = item.productName.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      return recipeFilter && searchFilter;
    }).toList();
    return Scaffold(
      appBar: AppBar(title: const Text("Maliyet Hesabı")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text(
                  "Hesaplanan ürün: ${calculatedNumber}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Ürün ara",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsetsGeometry.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Text("Sadece reçetesizler"),
                Switch(
                  value: showOnlyNoRecipe,
                  onChanged: (value) {
                    setState(() {
                      showOnlyNoRecipe = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredResults.isEmpty
                ? const Center(child: Text("Hesaplanan ürün bulunamadı"))
                : ListView.builder(
                    itemCount: filteredResults.length,
                    itemBuilder: (BuildContext context, int index) {
                      final item = filteredResults[index];
                      return Card(
                        child: ListTile(
                          title: Text(item.productName),
                          subtitle: item.hasRecipe
                              ? Text(
                                  "Maliyet ${item.totalCost.toStringAsFixed(2)} TL • Kâr %${item.profitMargin} • Satış: ${item.salePrice.toStringAsFixed(2)} TL",
                                )
                              : const Text("Reçete yok"),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Map<int, List<Map<String, dynamic>>> _groupByProduct(
    List<Map<String, dynamic>> rawData,
  ) {
    final Map<int, List<Map<String, dynamic>>> grouped = {};

    for (final row in rawData) {
      final productId = row['productId'] as int;

      if (grouped.containsKey(productId)) {
        grouped[productId]!.add(row);
      } else {
        grouped[productId] = [row];
      }
    }
    return grouped;
  }

  List<ProductCostResult> _calculateResults(
    Map<int, List<Map<String, dynamic>>> grouped,
  ) {
    final List<ProductCostResult> resultList = [];

    for (final entry in grouped.entries) {
      final rows = entry.value;
      final firstRow = rows.first;
      final productName = firstRow['productName'] as String;
      if (firstRow['recipeId'] == null) {
        resultList.add(
          ProductCostResult(
            productName: productName,
            recipes: [],
            totalCost: 0,
            salePrice: 0,
            profitMargin: (firstRow['profit_margin'] as num).toDouble(),
            hasRecipe: false,
          ),
        );
        continue;
      }

      final List<RawMaterial> materials = [];
      final List<Recipe> recipes = [];
      final List<RecipeDetails> recipeDetailsList = [];

      for (final row in rows) {
        materials.add(RawMaterial.fromJoinMap(row));
        recipes.add(Recipe.fromJoinMap(row));
        recipeDetailsList.add(RecipeDetails.fromJoinMap(row));
      }

      final product = Product(
        id: firstRow['productId'],
        name: productName,
        profitMargin: (firstRow['profit_margin'] as num).toDouble(),
      );

      final totalCost = calculator.calculateTotalCost(
        materials,
        recipes,
        product,
      );
      final salePrice = calculator.calculateSalePrice(
        materials,
        recipes,
        product,
      );

      resultList.add(
        ProductCostResult(
          productName: productName,
          recipes: recipeDetailsList,
          totalCost: totalCost,
          salePrice: salePrice,
          profitMargin: product.profitMargin,
          hasRecipe: true,
        ),
      );
    }
    return resultList;
  }

  Future<void> _loadAndCalculate() async {
    final rawData = await dbHelper.getAllProductsWithRecipes();
    final grouped = _groupByProduct(rawData);
    final calculated = _calculateResults(grouped);
    setState(() {
      result = calculated;
    });
  }
}
