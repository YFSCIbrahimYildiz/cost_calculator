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
  final searchController = TextEditingController();
  String searchQuery = "";

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
    final filtredRecipes = searchQuery.isEmpty
        ? allRecipes
        : allRecipes.where((item) {
            return item.productName.toLowerCase().contains(
              searchQuery.toLowerCase(),
            );
          }).toList();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text("Reçete")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- ÜRÜN SEÇ + HAMMADDE EKLE ---
              const Text(
                "Reçete Oluştur",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A3A5C),
                ),
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 20),
              // --- SEÇİLEN HAMMADDELER ---
              const Text(
                "Seçilen Hammaddeler",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A3A5C),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: selectedRecipes.isEmpty
                    ? Center(
                        child: Text(
                          selectedProduct == null
                              ? "Önce bir ürün seçin"
                              : "Henüz hammadde eklenmedi",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : ListView.builder(
                        itemCount: selectedRecipes.length,
                        itemBuilder: (BuildContext context, int index) {
                          final recipe = selectedRecipes[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          recipe.materialName,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1C2733),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "Miktar: ${recipe.quantity} • Fire: %${recipe.lossRate.toStringAsFixed(0)}",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _deleteRecipe(recipe.id),
                                    icon: const Icon(Icons.delete_outline),
                                    color: const Color(0xFFC0392B),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 24),
              // --- REÇETE LİSTESİ ---
              const Text(
                "Reçete Listesi",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A3A5C),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: "Ürün Ara",
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              filtredRecipes.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          "Ürün bulunamadı",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtredRecipes.length,
                      itemBuilder: (context, index) {
                        final item = filtredRecipes[index];
                        return Card(
                          child: InkWell(
                            onTap: () => _showRecipeDetailModal(item),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF1A3A5C,
                                      ).withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.receipt_long,
                                      color: Color(0xFF1A3A5C),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.productName,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1C2733),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "${item.recipes.length} hammadde",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        _deleteProductRecipe(item.productId),
                                    icon: const Icon(Icons.delete_outline),
                                    color: const Color(0xFFC0392B),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
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
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                const Text(
                  "Hammadde Ekle",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A3A5C),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownMenu<RawMaterial>(
                  width: double.infinity,
                  hintText: "Hammadde Seç",
                  enableFilter: true,
                  requestFocusOnTap: true,
                  menuHeight: 200,
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
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
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

                      if (!mounted) return;
                      Navigator.pop(context);
                      await _loadRecipes();
                      await _loadData();
                    },
                    child: const Text("Kaydet"),
                  ),
                ),
              ],
            ),
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
            "Bu ürünün reçetesini silmek istediğinize emin misiniz?",
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

  void _showRecipeDetailModal(ProductWithRecipes item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
                        "Fire",
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
              // Hammadde satırları
              SizedBox(
                height: 280,
                child: ListView.separated(
                  itemCount: item.recipes.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: Colors.grey.shade200),
                  itemBuilder: (BuildContext context, int index) {
                    final recipe = item.recipes[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              recipe.materialName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1C2733),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              recipe.quantity.toString(),
                              style: const TextStyle(fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "%${recipe.lossRate.toStringAsFixed(0)}",
                              style: const TextStyle(fontSize: 14),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
