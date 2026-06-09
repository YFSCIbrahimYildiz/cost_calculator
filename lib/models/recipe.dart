class Recipe {
  final int? id;
  final int productId;
  final int materialId;
  final double quantity;
  final double lossRate;

  Recipe({
    this.id,
    required this.productId,
    required this.materialId,
    required this.quantity,
    required this.lossRate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'material_id': materialId,
      'quantity': quantity,
      'loss_rate': lossRate,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      productId: map['product_id'],
      materialId: map['material_id'],
      quantity: map['quantity'],
      lossRate: map['loss_rate'],
    );
  }
  factory Recipe.fromJoinMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['recipeId'],
      productId: map['productId'],
      materialId: map['material_id'],
      quantity: (map['quantity'] as num).toDouble(),
      lossRate: (map['loss_rate'] as num).toDouble(),
    );
  }
}
