class RecipeDetails {
  final int id;
  final int materialId;
  final String materialName;
  final double quantity;
  final double lossRate;

  RecipeDetails({
    required this.id,
    required this.materialId,
    required this.materialName,
    required this.quantity,
    required this.lossRate,
  });

  factory RecipeDetails.fromMap(Map<String, dynamic> map) {
    return RecipeDetails(
      id: map['id'],
      materialId: map['material_id'],
      materialName: map['materialName'],
      quantity: (map['quantity'] as num).toDouble(),
      lossRate: (map['loss_rate'] as num).toDouble(),
    );
  }
  factory RecipeDetails.fromJoinMap(Map<String, dynamic> map) {
    return RecipeDetails(
      id: map['recipeId'],
      materialId: map['material_id'],
      materialName: map['materialName'],
      quantity: (map['quantity'] as num).toDouble(),
      lossRate: (map['loss_rate'] as num).toDouble(),
    );
  }
}
