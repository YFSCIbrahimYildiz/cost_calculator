import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maliyet_app/database/database_helper.dart';
import 'package:maliyet_app/models/product.dart';
import 'package:maliyet_app/models/product_with_recipes.dart';
import 'package:maliyet_app/models/raw_material.dart';
import 'package:maliyet_app/models/recipe.dart';
import 'package:maliyet_app/models/recipe_details.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final dbHelper = DatabaseHelper.instance;
  List<Product> products = [];
  Product? selectedProduct;
  List<RawMaterial> materials = [];
  List<RecipeDetails> selectedRecipes = [];
  List<ProductWithRecipes> allRecipes = [];
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final productData = await dbHelper.getAllProducts();
    final materialData = await dbHelper.getAllMaterials();
    final recipeRawData = await dbHelper.getAllRecipesWithDetails();
    setState(() {
      products = productData;
      materials = materialData;
      allRecipes = _groupRecipes(recipeRawData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reçete")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownMenu<Product>(
                    width: double.infinity,
                    hintText: "Ürün Seç",
                    enableFilter: true,
                    requestFocusOnTap: true,
                    onSelected: (product) async {
                      setState(() {
                        selectedProduct = product;
                      });
                      await _loadRecipes();
                    },
                    dropdownMenuEntries: products.map((product) {
                      return DropdownMenuEntry<Product>(
                        value: product,
                        label: product.name,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: selectedProduct == null
                      ? null
                      : _showAddMaterialModal,
                  child: const Text("Hammadde Ekle"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text("Seçilen Hammeddeler"),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: selectedRecipes.isEmpty
                  ? const Center(child: Text("Henüz Hammadde Eklenmedi"))
                  : ListView.builder(
                      itemCount: selectedRecipes.length,
                      itemBuilder: (BuildContext context, int index) {
                        final recipe = selectedRecipes[index];
                        return ListTile(
                          title: Text(recipe.materialName),
                          subtitle: Text(
                            "Miktar: ${recipe.quantity} • Fire: %${recipe.lossRate}",
                          ),
                          trailing: IconButton(
                            onPressed: () => _deleteRecipe(recipe.id),
                            icon: Icon(Icons.delete),
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(height: 24),
            const Text("Reçete Listesi"),
            const SizedBox(height: 8),
            Expanded(
              child: allRecipes.isEmpty
                  ? const Center(child: Text("Henüz reçete yok"))
                  : ListView.builder(
                      itemCount: allRecipes.length,
                      itemBuilder: (BuildContext context, int index) {
                        final item = allRecipes[index];
                        return Card(
                          child: ListTile(
                            title: Text(item.productName),
                            subtitle: Text("${item.recipes.length} hammadde"),
                            trailing: IconButton(
                              onPressed: () =>
                                  _deleteProductRecipe(item.productId),
                              icon: Icon(Icons.delete),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMaterialModal() {
    RawMaterial? selectedMaterial;
    final quantityController = TextEditingController();
    final lossRateController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsetsGeometry.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Hammadde Ekle"),
              const SizedBox(height: 12),
              DropdownMenu<RawMaterial>(
                width: double.infinity,
                hintText: "Hammadde Seç",
                enableFilter: true,
                requestFocusOnTap: true,
                onSelected: (material) {
                  selectedMaterial = material;
                },
                dropdownMenuEntries: materials.map((material) {
                  return DropdownMenuEntry(
                    value: material,
                    label: material.name,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: const InputDecoration(
                  labelText: "Kullanılan Miktar",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lossRateController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: const InputDecoration(
                  labelText: "Fire Oranı (%)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final quantity = double.tryParse(
                    quantityController.text.trim(),
                  );
                  final lossRate = double.tryParse(
                    lossRateController.text.trim(),
                  );

                  if (selectedMaterial == null ||
                      quantity == null ||
                      lossRate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Lütfen tüm alanları doldurunuz"),
                      ),
                    );
                    return;
                  }

                  final alreadyExists = selectedRecipes.any(
                    (recipe) => recipe.materialId == selectedMaterial!.id,
                  );

                  if (alreadyExists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Bu hammadde eklenmiş")),
                    );
                    return;
                  }

                  final saveRecipe = Recipe(
                    productId: selectedProduct!.id!,
                    materialId: selectedMaterial!.id!,
                    quantity: quantity,
                    lossRate: lossRate,
                  );

                  await dbHelper.insertRecipe(saveRecipe);

                  Navigator.pop(context);
                  await _loadRecipes();
                  setState(() {});
                },
                child: const Text("Kaydet"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadRecipes() async {
    if (selectedProduct == null) return;
    final data = await dbHelper.getInnerJoinRecipes(selectedProduct!.id!);
    setState(() {
      selectedRecipes = data;
    });
  }

  Future<void> _deleteRecipe(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Hammadde Sil"),
          content: const Text(
            "Bu hammadeyi reçeteden silmek istediğinize emin misiniz?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("İptal"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Sil"),
            ),
          ],
        );
      },
    );
    if (confirm == true) {
      await dbHelper.deleteRecipe(id);
      await _loadRecipes();
    }
  }

  List<ProductWithRecipes> _groupRecipes(List<Map<String, dynamic>> rawData) {
    final Map<int, ProductWithRecipes> grouped = {};
    for (final row in rawData) {
      final productId = row['productId'] as int;
      final recipeDetail = RecipeDetails.fromMap(row);

      if (grouped.containsKey(productId)) {
        grouped[productId]!.recipes.add(recipeDetail);
      } else {
        grouped[productId] = ProductWithRecipes(
          productId: productId,
          productName: row['productName'],
          recipes: [recipeDetail],
        );
      }
    }
    return grouped.values.toList();
  }

  Future<void> _deleteProductRecipe(int productId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Reçeteyi Sil"),
          content: const Text(
            "Bu ürünün reçetecisini silmek istediğinize emin misiniz?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("İptal"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Sil"),
            ),
          ],
        );
      },
    );
    if (confirm == true) {
      await dbHelper.deleteRecipesByProduct(productId);
      _loadData();
    }
  }
}
