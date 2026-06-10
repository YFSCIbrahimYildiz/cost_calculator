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
      appBar: AppBar(title: Text('Hammadde')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Hammadde Adı',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Alış Fiyatı',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Alış Miktarı',
                //alt başlık ya da açıklama ekle
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedUnit,
              decoration: const InputDecoration(
                labelText: 'Birim',
                border: OutlineInputBorder(),
              ),
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
            ElevatedButton(onPressed: _saveMaterial, child: Text('Ekle')),
            const SizedBox(height: 16),
            const Text('Kayıtlı Hammaddeler'),
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
                      return ListTile(
                        title: Text(material.name),
                        subtitle: Text(
                          '${material.purchasePrice} ₺ / ${material.purchaseQuantity} ${material.unit}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                final editNameController =
                                    TextEditingController(text: material.name);
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
                                          const Text('Hammadde Düzenle'),
                                          const SizedBox(height: 12),
                                          TextField(
                                            controller: editNameController,
                                            decoration: const InputDecoration(
                                              labelText: 'Hammadde adı',
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          TextField(
                                            controller: editPriceController,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(r'[0-9.]'),
                                              ),
                                            ],
                                            decoration: const InputDecoration(
                                              labelText: 'Alış Fiyatı',
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          TextField(
                                            controller: editQuantityController,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(r'[0-9.]'),
                                              ),
                                            ],
                                            decoration: const InputDecoration(
                                              labelText: 'Alış Miktarı',
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          DropdownButtonFormField<String>(
                                            initialValue: editSelectedUnit,
                                            decoration: const InputDecoration(
                                              labelText: 'Birim',
                                              border: OutlineInputBorder(),
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
                                          const SizedBox(height: 12),
                                          ElevatedButton(
                                            onPressed: () async {
                                              final name = editNameController
                                                  .text
                                                  .trim();
                                              final price = double.tryParse(
                                                editPriceController.text,
                                              );
                                              final quantity = double.tryParse(
                                                editQuantityController.text,
                                              );
                                              if (name.isEmpty ||
                                                  price == null ||
                                                  quantity == null ||
                                                  editSelectedUnit == null) {
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
                                                    purchaseQuantity: quantity,
                                                    unit: editSelectedUnit!,
                                                  );
                                              await dbHelper.updateMaterial(
                                                updateMaterial,
                                              );
                                              Navigator.pop(context);
                                              setState(() {});
                                            },
                                            child: const Text('Güncelle'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              icon: Icon(Icons.edit),
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
                                          child: Text('İptal'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: Text('Sil'),
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
                              icon: Icon(Icons.delete),
                            ),
                          ],
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
