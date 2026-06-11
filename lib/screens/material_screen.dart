import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maliyet_app/database/database_helper.dart';
import 'package:maliyet_app/models/raw_material.dart';

class MaterialScreen extends StatefulWidget {
  const MaterialScreen({super.key});

  @override
  State<MaterialScreen> createState() => _MaterialScreenState();
}

class _MaterialScreenState extends State<MaterialScreen> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();
  final dbHelper = DatabaseHelper.instance;

  final List<String> units = [
    'kilogram',
    'gram',
    'litre',
    'mililitre',
    'm\u{00B2}',
    'adet',
  ];
  String? selectedUnit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hammadde')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Yeni Hammadde Ekle",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A3A5C),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Hammadde Adı'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: const InputDecoration(labelText: 'Alış Fiyatı'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: const InputDecoration(labelText: 'Alış Miktarı'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedUnit,
              decoration: const InputDecoration(labelText: 'Birim'),
              items: units.map((unit) {
                return DropdownMenuItem<String>(value: unit, child: Text(unit));
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedUnit = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _saveMaterial, child: const Text('Ekle')),
            const SizedBox(height: 20),
            const Text(
              'Kayıtlı Hammaddeler',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A3A5C),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<RawMaterial>>(
                future: dbHelper.getAllMaterials(),
                builder: (BuildContext context, AsyncSnapshot<List<RawMaterial>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Hata ${snapshot.error}'));
                  }
                  final materials = snapshot.data ?? [];
                  if (materials.isEmpty) {
                    return const Center(
                      child: Text('Henüz hammadde eklenmedi'),
                    );
                  }
                  return ListView.builder(
                    itemCount: materials.length,
                    itemBuilder: (BuildContext context, int index) {
                      final material = materials[index];
                      return Card(
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
                                  Icons.inventory_2,
                                  color: Color(0xFF1A3A5C),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      material.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1C2733),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${material.purchasePrice.toStringAsFixed(2)} ₺ / ${material.purchaseQuantity.toStringAsFixed(0)} ${material.unit}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  final editNameController =
                                      TextEditingController(
                                        text: material.name,
                                      );
                                  final editPriceController =
                                      TextEditingController(
                                        text: material.purchasePrice.toString(),
                                      );
                                  final editQuantityController =
                                      TextEditingController(
                                        text: material.purchaseQuantity
                                            .toString(),
                                      );
                                  String? editSelectedUnit = material.unit;
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          left: 16,
                                          right: 16,
                                          top: 16,
                                          bottom:
                                              MediaQuery.of(
                                                context,
                                              ).viewInsets.bottom +
                                              16,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Center(
                                              child: Container(
                                                width: 40,
                                                height: 4,
                                                margin: const EdgeInsets.only(
                                                  bottom: 16,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade300,
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                ),
                                              ),
                                            ),
                                            const Text(
                                              'Hammadde Düzenle',
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1A3A5C),
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            TextField(
                                              controller: editNameController,
                                              decoration: const InputDecoration(
                                                labelText: 'Hammadde adı',
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            TextField(
                                              controller: editPriceController,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter.allow(
                                                  RegExp(r'[0-9.]'),
                                                ),
                                              ],
                                              decoration: const InputDecoration(
                                                labelText: 'Alış Fiyatı',
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            TextField(
                                              controller:
                                                  editQuantityController,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter.allow(
                                                  RegExp(r'[0-9.]'),
                                                ),
                                              ],
                                              decoration: const InputDecoration(
                                                labelText: 'Alış Miktarı',
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            DropdownButtonFormField<String>(
                                              initialValue: editSelectedUnit,
                                              decoration: const InputDecoration(
                                                labelText: 'Birim',
                                              ),
                                              items: units.map((unit) {
                                                return DropdownMenuItem<String>(
                                                  value: unit,
                                                  child: Text(unit),
                                                );
                                              }).toList(),
                                              onChanged: (newValue) {
                                                editSelectedUnit = newValue;
                                              },
                                            ),
                                            const SizedBox(height: 16),
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  final name =
                                                      editNameController.text
                                                          .trim();
                                                  final price = double.tryParse(
                                                    editPriceController.text,
                                                  );
                                                  final quantity =
                                                      double.tryParse(
                                                        editQuantityController
                                                            .text,
                                                      );
                                                  if (name.isEmpty ||
                                                      price == null ||
                                                      quantity == null ||
                                                      editSelectedUnit ==
                                                          null) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Lütfen tüm alanları doldurunuz.',
                                                        ),
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                  final existingMaterials =
                                                      await dbHelper
                                                          .getAllMaterials();
                                                  final alreadyExists =
                                                      existingMaterials.any(
                                                        (m) =>
                                                            m.name.toLowerCase() ==
                                                                name.toLowerCase() &&
                                                            m.id != material.id,
                                                      );
                                                  if (alreadyExists) {
                                                    if (!mounted) return;
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          "Bu isimde başka bir hammadde zaten var",
                                                        ),
                                                      ),
                                                    );
                                                    return;
                                                  }

                                                  final updateMaterial =
                                                      RawMaterial(
                                                        id: material.id,
                                                        name: name,
                                                        purchasePrice: price,
                                                        purchaseQuantity:
                                                            quantity,
                                                        unit: editSelectedUnit!,
                                                      );
                                                  await dbHelper.updateMaterial(
                                                    updateMaterial,
                                                  );
                                                  if (!mounted) return;
                                                  Navigator.pop(context);
                                                  setState(() {});
                                                },
                                                child: const Text('Güncelle'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(Icons.edit_outlined),
                                color: const Color(0xFF2E5A87),
                                visualDensity: VisualDensity.compact,
                              ),
                              IconButton(
                                onPressed: () async {
                                  final confirm = await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Hammaddeyi Sil'),
                                        content: const Text(
                                          'Bu hammaddeyi silmek istediğinize emin misiniz',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('İptal'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('Sil'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  if (confirm == true) {
                                    await dbHelper.deleteMaterial(material.id!);
                                    setState(() {});
                                  }
                                },
                                icon: const Icon(Icons.delete_outline),
                                color: const Color(0xFFC0392B),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveMaterial() async {
    final name = nameController.text.trim();
    final price = double.tryParse(priceController.text);
    final quantity = double.tryParse(quantityController.text);

    if (name.isEmpty ||
        price == null ||
        quantity == null ||
        selectedUnit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurunuz')),
      );
      return;
    }
    final existingMaterials = await dbHelper.getAllMaterials();
    final alreadyExists = existingMaterials.any(
      (m) => m.name.toLowerCase() == name.toLowerCase(),
    );
    if (alreadyExists) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bu isimde hammadde zaten var")),
      );
      return;
    }

    final material = RawMaterial(
      name: name,
      purchasePrice: price,
      purchaseQuantity: quantity,
      unit: selectedUnit!,
    );

    await dbHelper.insertMaterial(material);

    nameController.clear();
    priceController.clear();
    quantityController.clear();
    setState(() {
      selectedUnit = null;
    });
  }
}
