import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maliyet_app/database/database_helper.dart';
import 'package:maliyet_app/models/product.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final nameController = TextEditingController();
  final profitMarginController = TextEditingController();
  final dbHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ürünler")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildForm(),
            const SizedBox(height: 16),
            const Text("Kayıtlı Ürünler"),
            const SizedBox(height: 8),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: "Ürün Adı",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: profitMarginController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          decoration: InputDecoration(
            labelText: "Kar Marjı (%)",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: _saveProduct, child: const Text("Ekle")),
      ],
    );
  }

  bool _isValid(
    TextEditingController nameCtrl,
    TextEditingController marginCtrl,
  ) {
    final name = nameCtrl.text;
    final profitMargin = double.tryParse(marginCtrl.text);

    if (name.isEmpty || profitMargin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doğru doldurunuz")),
      );
      return false;
    }
    return true;
  }

  Future<void> _saveProduct() async {
    if (!_isValid(nameController, profitMarginController)) return;

    final product = Product(
      name: nameController.text,
      profitMargin: double.parse(profitMarginController.text),
    );
    await dbHelper.insertProduct(product);
    nameController.clear();
    profitMarginController.clear();
    setState(() {});
  }

  Widget _buildList() {
    return FutureBuilder<List<Product>>(
      future: dbHelper.getAllProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Hata: ${snapshot.error}"));
        }
        final products = snapshot.data ?? [];
        if (products.isEmpty) {
          return const Center(child: Text("Henüz ürün eklenmedi"));
        }
        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (BuildContext context, int index) {
            final product = products[index];
            return ListTile(
              title: Text(product.name),
              subtitle: Text("Kar marjı: %${product.profitMargin}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _showEditModal(product),
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () => _deleteProduct(product.id!),
                    icon: const Icon(Icons.delete),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteProduct(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ürünü Sil"),
          content: const Text("Bu ürünü silmek istediğinize emin misiz?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("İptal"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Sil"),
            ),
          ],
        );
      },
    );
    if (confirm == true) {
      await dbHelper.deleteProduct(id);
      setState(() {});
    }
  }

  void _showEditModal(Product product) {
    final editNameController = TextEditingController(text: product.name);
    final editMarginController = TextEditingController(
      text: product.profitMargin.toString(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsetsGeometry.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Ürün Düzenle"),
              const SizedBox(height: 12),
              TextField(
                controller: editNameController,
                decoration: const InputDecoration(
                  labelText: "Ürün Adı",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: editMarginController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: InputDecoration(
                  labelText: "Kar Marjı (%)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  if (!_isValid(editNameController, editMarginController))
                    return;
                  final updateProduct = Product(
                    id: product.id,
                    name: editNameController.text,
                    profitMargin: double.tryParse(editMarginController.text)!,
                  );
                  Navigator.pop(context);
                  await dbHelper.updateProduct(updateProduct);
                  setState(() {});
                },
                child: const Text("Güncelle"),
              ),
            ],
          ),
        );
      },
    );
  }
}
