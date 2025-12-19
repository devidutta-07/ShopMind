import 'dart:convert';

class ShoppingItem {
  String id;
  String name;
  String? price;
  int quantity;
  bool isPurchased;
  String category;
  DateTime dateAdded;

  ShoppingItem({
    required this.id,
    required this.name,
    this.price,
    this.quantity = 1,
    this.isPurchased = false,
    this.category = 'Other',
    DateTime? dateAdded,
  }) : dateAdded = dateAdded ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'isPurchased': isPurchased,
      'category': category,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      quantity: map['quantity'] ?? 1,
      isPurchased: map['isPurchased'] ?? false,
      category: map['category'] ?? 'Other',
      dateAdded: map['dateAdded'] != null 
          ? DateTime.parse(map['dateAdded']) 
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory ShoppingItem.fromJson(String source) =>
      ShoppingItem.fromMap(json.decode(source));
}
