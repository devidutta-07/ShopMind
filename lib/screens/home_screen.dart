// ignore_for_file: deprecated_member_use, unused_element

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/shopping_item.dart';
import '../providers/app_provider.dart';
import '../services/pdf_service.dart';
import 'add_edit_item_screen.dart';
import 'shopping_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BannerAd? _bannerAd = null;
  final bool _isAdLoaded = false;
  
  // Filter State
  Set<String> _selectedFilters = {}; 

  @override
  void initState() {
    super.initState();
  }

  void _loadBannerAd() {
    // AdMob disabled for fast app startup
  }

  void _retryLoadBannerAd() {}

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _navigateToAddEditItem(BuildContext context, [ShoppingItem? item]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditItemScreen(item: item),
      ),
    );

    if (result != null && context.mounted) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      if (item != null) {
        provider.updateItem(result);
      } else {
        provider.addItem(result);
      }
    }
  }

  void _showAddCategoryDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Category'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Category Name'),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Provider.of<AppProvider>(context, listen: false).addCategory(
                  controller.text.trim(),
                  Colors.grey.toARGB32(),
                  Icons.category.codePoint,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        Set<String> tempFilters = Set.from(_selectedFilters);
        final primaryColor = Theme.of(context).colorScheme.primary;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final categories = provider.categories;

            return AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filter Items', style: TextStyle(fontWeight: FontWeight.w900)),
                  if (tempFilters.isNotEmpty)
                    TextButton(
                      onPressed: () => setDialogState(() => tempFilters.clear()),
                      child: Text('Clear', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    )
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...categories.map((category) {
                      final isSelected = tempFilters.contains(category);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: InkWell(
                          onTap: () {
                            setDialogState(() {
                              if (isSelected) {
                                tempFilters.remove(category);
                              } else {
                                tempFilters.add(category);
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? primaryColor.withAlpha(38)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? primaryColor : Theme.of(context).dividerColor.withAlpha(51),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(category),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? primaryColor : Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check, color: primaryColor, size: 20),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showAddCategoryDialog(context);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Create Category'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(153))),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedFilters = tempFilters;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMonthPicker(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    DateTime tempDate = provider.selectedDate;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: 400,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          setSheetState(() {
                            tempDate = DateTime(tempDate.year - 1, tempDate.month);
                          });
                        },
                      ),
                      Text('${tempDate.year}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          setSheetState(() {
                            tempDate = DateTime(tempDate.year + 1, tempDate.month);
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 1.5),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        final monthDate = DateTime(tempDate.year, index + 1);
                        final isSelected = index + 1 == tempDate.month;
                        return InkWell(
                          onTap: () {
                            provider.updateSelectedDate(monthDate);
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isSelected ? Theme.of(context).colorScheme.primary.withAlpha(51) : null,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              DateFormat('MMM').format(monthDate),
                              style: TextStyle(
                                color: isSelected ? Theme.of(context).colorScheme.primary : null,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showBudgetDialog(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final currentBudget = provider.totalBudget;
    final controller = TextEditingController(text: currentBudget > 0 ? currentBudget.toString() : '');
    final currency = provider.currencySymbol;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Budget for ${DateFormat('MMMM yyyy').format(provider.selectedDate)}'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Budget Amount',
            prefixIcon: const Icon(Icons.attach_money),
            prefixText: currency,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0.0;
              provider.setMonthlyBudget(provider.selectedDate, amount);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _handleItemCheck(ShoppingItem item, bool? value) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final currency = provider.currencySymbol;
    
    if (value == true) {
      final totalPriceController = TextEditingController(text: item.price ?? '');
      final quantityController = TextEditingController(text: item.quantity.toString());
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Purchase Details for ${item.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  prefixIcon: Icon(Icons.shopping_basket),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: totalPriceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Total Price',
                  prefixIcon: const Icon(Icons.attach_money),
                  prefixText: currency,
                  helperText: 'For all items combined',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                int qty = int.tryParse(quantityController.text) ?? 1;
                double total = double.tryParse(totalPriceController.text) ?? 0.0;
                double unitPrice = qty > 0 ? total / qty : 0.0;
                
                provider.markAsPurchased(item.id, unitPrice.toString(), qty);
                Navigator.pop(context);
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
    } else {
      provider.unmarkPurchased(item.id);
    }
  }

  void _showEditTransactionDialog(ShoppingItem item) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final currency = provider.currencySymbol;
    
    double unitPrice = double.tryParse(item.price ?? '0') ?? 0.0;
    double total = unitPrice * item.quantity;
    
    final totalPriceController = TextEditingController(text: total > 0 ? total.toString() : '');
    final quantityController = TextEditingController(text: item.quantity.toString());
    DateTime selectedDate = item.dateAdded;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Edit ${item.name}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withAlpha(100)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
                          const Icon(Icons.calendar_today, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      prefixIcon: Icon(Icons.shopping_basket),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: totalPriceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Total Price',
                      prefixIcon: const Icon(Icons.attach_money),
                      prefixText: currency,
                    ),
                  ),
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween, // FIX: Use actionsAlignment
            actions: [
              // Delete Button (Left)
              TextButton(
                onPressed: () {
                  provider.deleteItem(item.id);
                  Navigator.pop(context);
                },
                child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
              // Action Buttons (Right)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      int qty = int.tryParse(quantityController.text) ?? 1;
                      double total = double.tryParse(totalPriceController.text) ?? 0.0;
                      double unitPrice = qty > 0 ? total / qty : 0.0;
        
                      ShoppingItem updatedItem = ShoppingItem(
                        id: item.id,
                        name: item.name,
                        category: item.category,
                        isPurchased: true,
                        quantity: qty,
                        price: unitPrice.toString(),
                        dateAdded: selectedDate,
                      );
                      
                      provider.updateItem(updatedItem);
                      Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    return provider.getCategoryColor(category);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final currency = provider.currencySymbol;
    
    final selectedDate = provider.selectedDate;
    final targetMonth = DateFormat('yyyy-MM').format(selectedDate);
    final allItems = provider.items;
    
    final pendingItems = allItems.where((i) => !i.isPurchased).toList();
    final purchasedItems = allItems.where((i) {
       if (!i.isPurchased) return false;
       return DateFormat('yyyy-MM').format(i.dateAdded) == targetMonth;
    }).toList();

    List<ShoppingItem> filteredPurchasedItems = purchasedItems;
    if (_selectedFilters.isNotEmpty) {
      filteredPurchasedItems = purchasedItems.where((item) => _selectedFilters.contains(item.category)).toList();
    }

    filteredPurchasedItems.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));

    Map<String, List<ShoppingItem>> groupedHistory = {};
    for (var item in filteredPurchasedItems) {
      final dateKey = DateFormat('d').format(item.dateAdded); 
      if (!groupedHistory.containsKey(dateKey)) groupedHistory[dateKey] = [];
      groupedHistory[dateKey]!.add(item);
    }

    final monthlyBudget = provider.totalBudget;
    final monthlySpent = provider.totalSpent;
    final remaining = provider.remainingBudget;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // App Title
                      Flexible(
                        child: Text(
                          'ShopMind',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      
                      // Controls
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () => _showMonthPicker(context),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    DateFormat('MMM. yyyy').format(selectedDate),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(Icons.arrow_drop_down, size: 18),
                                ],
                              ),
                            ),
                          ),
                          // Share Button
                          IconButton(
                            onPressed: () => PdfService.generateAndPrintPdf(
                              filteredPurchasedItems, monthlyBudget, monthlySpent, selectedDate, currency
                            ),
                            icon: const Icon(Icons.share, size: 22),
                            tooltip: 'Share Report',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                            style: IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                          ),
                          // Filter Button
                          IconButton(
                            onPressed: _showFilterDialog,
                            icon: Icon(
                              Icons.filter_list_rounded, 
                              size: 24,
                              color: _selectedFilters.isNotEmpty 
                                  ? Theme.of(context).colorScheme.primary 
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                            tooltip: 'Filter',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                            style: IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Budget Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E), 
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withAlpha(100), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(80),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        )
                      ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Budget', style: TextStyle(color: Colors.white.withAlpha(153))),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('$currency${monthlyBudget.toStringAsFixed(2)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.arrow_upward, color: Color(0xFF00C853), size: 16),
                                      const SizedBox(width: 4),
                                      Text('Remaining', style: TextStyle(color: Colors.white.withAlpha(153), fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text('$currency${remaining.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF00C853), fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.arrow_downward, color: Color(0xFFFF5252), size: 16),
                                      const SizedBox(width: 4),
                                      Text('Expenses', style: TextStyle(color: Colors.white.withAlpha(153), fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text('$currency${monthlySpent.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFFFF5252), fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _showBudgetDialog(context),
                            icon: const Icon(Icons.account_balance_wallet, size: 18),
                            label: const Text('Manage Budget'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white24),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),

                  // Shopping List Navigation Card
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ShoppingListScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF212023),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF2D2C30), width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF242B26),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.assignment_outlined, color: Color(0xFFDBE6D5), size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Shopping List',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF9C27B0),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${pendingItems.length} pending ${pendingItems.length == 1 ? 'item' : 'items'}',
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF252427),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF353338), width: 1),
                            ),
                            child: Text(
                              '${pendingItems.length} ${pendingItems.length == 1 ? 'item' : 'items'}',
                              style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Transactions History List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  // Grouped History Transactions for Selected Month
                  if (groupedHistory.isNotEmpty)
                    ...groupedHistory.entries.map((entry) {
                      final date = entry.value.first.dateAdded;
                      final dayStr = DateFormat('dd').format(date);
                      final dayName = DateFormat('EEEE').format(date);
                      final monthStr = DateFormat('MMM. yyyy').format(date);
                      
                      double dailyTotal = entry.value.fold(0.0, (sum, i) => sum + ((double.tryParse(i.price ?? '0') ?? 0) * i.quantity));

                      return Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 8, top: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Text(dayStr, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(dayName, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(153), fontWeight: FontWeight.bold)),
                                      Text(monthStr, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(153), fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('-$currency${dailyTotal.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFFFF5252), fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          ...entry.value.map((item) => _buildHistoryItemRow(item)),
                        ],
                      );
                    })
                  else
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.withAlpha(100)),
                            const SizedBox(height: 16),
                            Text(
                              'No transactions in ${DateFormat('MMMM yyyy').format(selectedDate)}', 
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                  const SizedBox(height: 80),
                ],
              ),
            ),
            
            if (_isAdLoaded && _bannerAd != null)
              SafeArea(
                top: false,
                child: Container(
                  alignment: Alignment.center,
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditItem(context),
        backgroundColor: const Color(0xFF8E24AA),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPendingItemCard(ShoppingItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Checkbox(
          value: false, 
          onChanged: (val) => _handleItemCheck(item, true),
          shape: const CircleBorder(),
        ),
        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(item.category),
        trailing: IconButton(
          icon: const Icon(Icons.edit, size: 18),
          onPressed: () => _navigateToAddEditItem(context, item),
        ),
      ),
    );
  }

  Widget _buildHistoryItemRow(ShoppingItem item) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final currency = provider.currencySymbol;
    final totalCost = (double.tryParse(item.price ?? '0') ?? 0) * item.quantity;
    
    return GestureDetector(
      onTap: () => _showEditTransactionDialog(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withAlpha(128),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_bag_outlined, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${item.quantity} x $currency${item.price} (unit)', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withAlpha(128))),
                ],
              ),
            ),
            Text(
              '-$currency${totalCost.toStringAsFixed(2)}',
              style: const TextStyle(color: Color(0xFFFF5252), fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
