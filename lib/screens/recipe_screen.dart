import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maliyet_app/database/database_helper.dart';
import 'package:maliyet_app/models/product.dart';
import 'package:maliyet_app/models/raw_material.dart';
import 'package:maliyet_app/models/recipe.dart';

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
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final productData = await dbHelper.getAllProducts();
    final materialData = await dbHelper.getAllMaterials();
    setState(() {
      products = productData;
      materials = materialData;
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
                    onSelected: (product) {
                      setState(() {
                        selectedProduct = product;
                      });
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

                  final saveRecipe = Recipe(
                    productId: selectedProduct!.id!,
                    materialId: selectedMaterial!.id!,
                    quantity: double.tryParse(quantityController.text)!,
                    lossRate: double.tryParse(lossRateController.text)!,
                  );

                  await dbHelper.insertRecipe(saveRecipe);

                  Navigator.pop(context);
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
}
