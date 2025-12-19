import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shopping_item.dart';

class StorageService {
  static const String _storageKey = 'shopping_list';

  Future<void> saveItems(List<ShoppingItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(
      items.map((item) => item.toMap()).toList(),
    );
    await prefs.setString(_storageKey, encodedData);
  }

  Future<List<ShoppingItem>> getItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_storageKey);
    
    if (encodedData == null) return [];

    final List<dynamic> decodedData = json.decode(encodedData);
    return decodedData.map((item) => ShoppingItem.fromMap(item)).toList();
  }
}
