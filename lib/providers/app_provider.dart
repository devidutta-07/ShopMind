import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shopping_item.dart';
import '../models/user_profile.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class AppProvider with ChangeNotifier {
  List<ShoppingItem> _items = [];
  UserProfile _userProfile = UserProfile();
  ThemeMode _themeMode = ThemeMode.system;
  DateTime _selectedDate = DateTime.now();
  String _currencySymbol = '\$';
  
  List<String> _categories = ['Groceries', 'Electronics', 'Home', 'Personal', 'Other'];
  
  // Maps to store custom properties for categories
  Map<String, int> _categoryColors = {};
  Map<String, int> _categoryIcons = {};

  // Budgets per month (Key: "yyyy-MM", Value: Budget Amount)
  Map<String, double> _monthlyBudgets = {};

  List<ShoppingItem> get items => _items;
  UserProfile get userProfile => _userProfile;
  ThemeMode get themeMode => _themeMode;
  DateTime get selectedDate => _selectedDate;
  String get currencySymbol => _currencySymbol;
  List<String> get categories => _categories;

  AppProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Items
    final String? itemsData = prefs.getString('shopping_list');
    if (itemsData != null) {
      final List<dynamic> decodedData = json.decode(itemsData);
      _items = decodedData.map((item) => ShoppingItem.fromMap(item)).toList();
    }

    // Load Profile
    final String? profileData = prefs.getString('user_profile');
    if (profileData != null) {
      _userProfile = UserProfile.fromJson(profileData);
    }

    // Load Theme
    final bool? isDark = prefs.getBool('is_dark_mode');
    if (isDark != null) {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    }

    // Load Currency
    _currencySymbol = prefs.getString('currency_symbol') ?? '\$';

    // Load Categories
    final List<String>? categoriesData = prefs.getStringList('categories');
    if (categoriesData != null) {
      _categories = categoriesData;
    }

    // Load Category Metadata
    final String? colorsData = prefs.getString('category_colors');
    if (colorsData != null) {
      _categoryColors = Map<String, int>.from(json.decode(colorsData));
    }
    final String? iconsData = prefs.getString('category_icons');
    if (iconsData != null) {
      _categoryIcons = Map<String, int>.from(json.decode(iconsData));
    }

    // Initialize Defaults for base categories if missing
    _initDefaultCategoryMetadata();

    // Load Monthly Budgets
    final String? budgetsData = prefs.getString('monthly_budgets');
    if (budgetsData != null) {
      Map<String, dynamic> decoded = json.decode(budgetsData);
      _monthlyBudgets = decoded.map((key, value) => MapEntry(key, (value as num).toDouble()));
    }

    notifyListeners();
  }

  void _initDefaultCategoryMetadata() {
    // Defaults matches the previous switch-case logic
    if (!_categoryColors.containsKey('Groceries')) _categoryColors['Groceries'] = 0xFFFFCA28;
    if (!_categoryColors.containsKey('Electronics')) _categoryColors['Electronics'] = 0xFF4A90E2;
    if (!_categoryColors.containsKey('Home')) _categoryColors['Home'] = 0xFF8DBF42;
    if (!_categoryColors.containsKey('Personal')) _categoryColors['Personal'] = 0xFFFF4A4A;
    if (!_categoryColors.containsKey('Other')) _categoryColors['Other'] = 0xFF9E9E9E;

    if (!_categoryIcons.containsKey('Groceries')) _categoryIcons['Groceries'] = Icons.shopping_bag.codePoint;
    if (!_categoryIcons.containsKey('Electronics')) _categoryIcons['Electronics'] = Icons.devices.codePoint;
    if (!_categoryIcons.containsKey('Home')) _categoryIcons['Home'] = Icons.home.codePoint;
    if (!_categoryIcons.containsKey('Personal')) _categoryIcons['Personal'] = Icons.person.codePoint;
    if (!_categoryIcons.containsKey('Other')) _categoryIcons['Other'] = Icons.category.codePoint;
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(
      _items.map((item) => item.toMap()).toList(),
    );
    await prefs.setString('shopping_list', encodedData);
    notifyListeners();
  }

  Future<void> _saveBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('monthly_budgets', json.encode(_monthlyBudgets));
    notifyListeners();
  }

  Future<void> _saveCategoryMetadata() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('category_colors', json.encode(_categoryColors));
    await prefs.setString('category_icons', json.encode(_categoryIcons));
  }

  Future<void> setCurrency(String symbol) async {
    _currencySymbol = symbol;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency_symbol', symbol);
    notifyListeners();
  }

  Future<void> addCategory(String category, int colorValue, int iconCodePoint) async {
    if (!_categories.contains(category)) {
      _categories.add(category);
      _categoryColors[category] = colorValue;
      _categoryIcons[category] = iconCodePoint;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('categories', _categories);
      await _saveCategoryMetadata();
      
      notifyListeners();
    }
  }

  Color getCategoryColor(String category) {
    if (_categoryColors.containsKey(category)) {
      return Color(_categoryColors[category]!);
    }
    return Colors.grey;
  }

  IconData getCategoryIcon(String category) {
    if (_categoryIcons.containsKey(category)) {
      // ignore: non_const_argument_for_const_parameter
      return IconData(_categoryIcons[category]!, fontFamily: 'MaterialIcons');
    }
    return Icons.category;
  }

  void updateSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  Future<void> setMonthlyBudget(DateTime date, double budget) async {
    final key = DateFormat('yyyy-MM').format(date);
    _monthlyBudgets[key] = budget;
    await _saveBudgets();
    notifyListeners();
  }

  double getBudgetForMonth(DateTime date) {
    final key = DateFormat('yyyy-MM').format(date);
    return _monthlyBudgets[key] ?? 0.0;
  }

  void addItem(ShoppingItem item) {
    _items.add(item);
    _saveItems();
  }

  void updateItem(ShoppingItem updatedItem) {
    final index = _items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _items[index] = updatedItem;
      _saveItems();
    }
  }

  void deleteItem(String id) {
    _items.removeWhere((item) => item.id == id);
    _saveItems();
  }

  void markAsPurchased(String id, String? price, int quantity) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index].isPurchased = true;
      if (price != null) {
        _items[index].price = price;
      }
      _items[index].quantity = quantity;
      _saveItems();
    }
  }

  void unmarkPurchased(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index].isPurchased = false;
      _saveItems();
    }
  }

  void updateUserProfile(UserProfile profile) {
    _userProfile = profile;
    SharedPreferences.getInstance().then((prefs) {
         prefs.setString('user_profile', _userProfile.toJson());
    });
    notifyListeners();
  }

  void toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', isDark);
    notifyListeners();
  }

  void logout() {
    _userProfile = UserProfile();
    SharedPreferences.getInstance().then((prefs) {
         prefs.setString('user_profile', _userProfile.toJson());
    });
    notifyListeners();
  }
  
  double getTotalSpentForMonth(DateTime date) {
    final targetMonth = DateFormat('yyyy-MM').format(date);
    
    return _items
        .where((item) {
          if (!item.isPurchased || item.price == null) return false;
          final itemMonth = DateFormat('yyyy-MM').format(item.dateAdded);
          return itemMonth == targetMonth;
        })
        .fold(0.0, (sum, item) {
          double price = double.tryParse(item.price!) ?? 0.0;
          return sum + (price * item.quantity);
        });
  }
  
  double get totalSpent => getTotalSpentForMonth(_selectedDate);
  double get totalBudget => getBudgetForMonth(_selectedDate);
  double get remainingBudget => totalBudget - totalSpent;
}
