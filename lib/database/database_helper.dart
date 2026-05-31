import 'package:maliyet_app/models/product.dart';
import 'package:maliyet_app/models/raw_material.dart';
import 'package:maliyet_app/models/recipe.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cost_app.db');

    return await openDatabase(path, version: 1, onCreate: _createTable);
  }

  Future<void> _createTable(Database db, int version) async {
    await db.execute('''
CREATE TABLE materials (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, purchase_price REAL NOT NULL, purchase_quantity REAL NOT NULL, unit TEXT NOT NULL)
''');

    await db.execute('''
CREATE TABLE products(
id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, profit_margin REAL NOT NULL
)
''');

    await db.execute(
      '''CREATE TABLE recipes(id INTEGER PRIMARY KEY AUTOINCREMENT, product_id INTEGER NOT NULL, material_id INTEGER NOT NULL, quantity REAL NOT NULL, loss_rate REAL NOT NULL, FOREIGN KEY(product_id) REFERENCES products(id), FOREIGN KEY (material_id) REFERENCES materials (id))''',
    );
  }

  Future<int> insertMaterial(RawMaterial material) async {
    final db = await database;
    return await db.insert('materials', material.toMap());
  }

  Future<List<RawMaterial>> getAllMaterials() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('materials');
    return List.generate(maps.length, (i) {
      return RawMaterial.fromMap(maps[i]);
    });
  }

  Future<int> updateMaterial(RawMaterial material) async {
    final db = await database;
    return await db.update(
      'materials',
      material.toMap(),
      where: 'id=?',
      whereArgs: [material.id],
    );
  }

  Future<int> deleteMaterial(int id) async {
    final db = await database;
    return await db.delete('materials', where: 'id=?', whereArgs: [id]);
  }

  //product

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id=?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id=?', whereArgs: [id]);
  }

  //recipe
  Future<int> insertRecipe(Recipe recipe) async {
    final db = await database;
    return await db.insert('recipes', recipe.toMap());
  }

  Future<List<Recipe>> getAllRecipes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('recipes');
    return List.generate(maps.length, (i) {
      return Recipe.fromMap(maps[i]);
    });
  }

  Future<int> updateRecipe(Recipe recipe) async {
    final db = await database;
    return await db.update(
      'recipes',
      recipe.toMap(),
      where: 'id=?',
      whereArgs: [recipe.id],
    );
  }

  Future<int> deleteRecipe(int id) async {
    final db = await database;
    return await db.delete('recipes', where: 'id=?', whereArgs: [id]);
  }
}
