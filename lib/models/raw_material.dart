class RawMaterial {
  final int? id;
  final String name;
  final double puchasePrice;
  final double puchaseQuantity;
  final String unit;

  RawMaterial({
    this.id,
    required this.name,
    required this.puchasePrice,
    required this.puchaseQuantity,
    required this.unit,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'purchase_price': puchasePrice,
      'puchase_quantity': puchaseQuantity,
      'unit': unit,
    };
  }

  factory RawMaterial.fromMap(Map<String, dynamic> map) {
    return RawMaterial(
      id: map['id'],
      name: map['name'],
      puchasePrice: map['purchase_price'],
      puchaseQuantity: map['purchase_quantity'],
      unit: map['unit'],
    );
  }

  
}
