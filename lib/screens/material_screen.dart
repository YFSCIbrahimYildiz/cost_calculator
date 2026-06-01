import 'package:flutter/material.dart';
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
              decoration: const InputDecoration(
                labelText: 'Alış Fiyatı',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: 'Alış Miktarı',
                //alt başlık ya da açıklama ekle
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedUnit,
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
                builder:
                    (
                      BuildContext context,
                      AsyncSnapshot<List<RawMaterial>> snapshot,
                    ) {
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
    final name = nameController.text;
    final price = double.parse(priceController.text);
    final quantity = double.parse(quantityController.text);

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
