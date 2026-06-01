class RawMaterial {
  final int? id;
  final String name;
  final double purchasePrice;
  final double purchaseQuantity;
  final String unit;

  RawMaterial({
    this.id,
    required this.name,
    required this.purchasePrice,
    required this.purchaseQuantity,
    required this.unit,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'purchase_price': purchasePrice,
      'purchase_quantity': purchaseQuantity,
      'unit': unit,
    };
  }

  factory RawMaterial.fromMap(Map<String, dynamic> map) {
    return RawMaterial(
      id: map['id'],
      name: map['name'],
      purchasePrice: map['purchase_price'],
      purchaseQuantity: map['purchase_quantity'],
      unit: map['unit'],
    );
  }
}
