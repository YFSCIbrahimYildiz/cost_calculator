import 'package:flutter/material.dart';
import 'package:maliyet_app/database/database_helper.dart';
import 'package:maliyet_app/models/material_cost_line.dart';
import 'package:maliyet_app/models/product.dart';
import 'package:maliyet_app/models/product_cost_result.dart';
import 'package:maliyet_app/models/raw_material.dart';
import 'package:maliyet_app/models/recipe.dart';
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
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
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
          Padding(
            padding: const EdgeInsetsGeometry.fromLTRB(12, 0, 12, 8),
            child: Row(
              children: [
                Text(
                  "Hesaplanan: $calculatedNumber",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
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
                        child: InkWell(
                          onTap: item.hasRecipe
                              ? () => _showCostDetailModal(item)
                              : null,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.productName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1C2733),
                                        ),
                                      ),
                                    ),
                                    if (!item.hasRecipe)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          "Reçete yok",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                if (item.hasRecipe) ...[
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Maliyet",
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            Text(
                                              "${item.totalCost.toStringAsFixed(2)} ₺",
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF1C2733),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Satış",
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              "${item.salePrice.toStringAsFixed(2)} ₺",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFD98C0A),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF1A3A5C,
                                          ).withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          "%${item.profitMargin.toStringAsFixed(0)}",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1A3A5C),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
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
      final List<MaterialCostLine> costLines = [];

      for (final row in rows) {
        final material = RawMaterial.fromJoinMap(row);
        final recipe = Recipe.fromJoinMap(row);

        materials.add(material);
        recipes.add(recipe);

        final lineCost = calculator.calculateMaterialCost(material, recipe);

        costLines.add(
          MaterialCostLine(
            materialName: row['materialName'],
            quantity: (row['quantity'] as num).toDouble(),
            lossRate: (row['loss_rate'] as num).toDouble(),
            cost: lineCost,
          ),
        );
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
          recipes: costLines,
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

  void _showCostDetailModal(ProductCostResult item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsetsGeometry.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                item.productName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A3A5C),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A3A5C).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Expanded(
                      flex: 3,
                      child: Text(
                        "Hammadde",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Miktar",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Kayıp",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        "Maliyet",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),

              ...item.recipes.map((line) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          line.materialName,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          line.quantity.toString(),
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "%${line.lossRate.toStringAsFixed(0)}",
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          "${line.cost.toStringAsFixed(2)} ₺",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    _summaryRow(
                      "Ürün Maliyeti",
                      "${item.totalCost.toStringAsFixed(2)} ₺",
                      const Color(0xFF1C2733),
                    ),
                    const SizedBox(height: 8),
                    _summaryRow(
                      "Kâr Oranı",
                      "%${item.profitMargin.toStringAsFixed(0)}",
                      const Color(0xFF1C2733),
                    ),
                    const Divider(height: 20),
                    _summaryRow(
                      "Satış Fiyatı",
                      "${item.salePrice.toStringAsFixed(2)} ₺",
                      const Color(0xFFD98C0A),
                      isBig: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryRow(
    String label,
    String value,
    Color valueColor, {
    bool isBig = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBig ? 15 : 14,
            color: Colors.grey.shade700,
            fontWeight: isBig ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBig ? 18 : 14,
            fontWeight: isBig ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}






// ListTile(
//                                   title: Text(item.productName),
//                                   subtitle: item.hasRecipe
//                                       ? Text(
//                                           "Maliyet ${item.totalCost.toStringAsFixed(2)} TL • Kâr %${item.profitMargin} • Satış: ${item.salePrice.toStringAsFixed(2)} TL",
//                                         )
//                                       : const Text("Reçete yok"),
                                  
//                                 ),



// Text(
//                 item.productName,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 16),

//               Row(
//                 children: const [
//                   Expanded(
//                     flex: 3,
//                     child: Text(
//                       "Hammadde",
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   Expanded(
//                     flex: 2,
//                     child: Text(
//                       "Miktar",
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   Expanded(
//                     flex: 2,
//                     child: Text(
//                       "Kayıp",
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   Expanded(
//                     flex: 2,
//                     child: Text(
//                       "Maliyet",
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ],
//               ),


