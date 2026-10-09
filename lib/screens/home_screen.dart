import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  // Expanded Date Groups Tracking (key = dateKey)
  final Set<String> _expandedDateGroups = {};

  @override
  void initState() {
    super.initState();
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

  void _showMonthPicker(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    DateTime tempDate = provider.selectedDate;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
                        icon: const Icon(Icons.chevron_left, color: Colors.white),
                        onPressed: () {
                          setSheetState(() {
                            tempDate = DateTime(tempDate.year - 1, tempDate.month);
                          });
                        },
                      ),
                      Text(
                        '${tempDate.year}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: Colors.white),
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
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 1.5,
                      ),
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
                              color: isSelected ? Colors.white.withAlpha(40) : null,
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected ? Border.all(color: Colors.white) : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              DateFormat('MMM').format(monthDate),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
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
        backgroundColor: const Color(0xFF121212),
        title: Text(
          'Set Budget for ${DateFormat('MMM. yyyy').format(provider.selectedDate)}',
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Budget Amount',
            labelStyle: const TextStyle(color: Color(0xFFA1A1AA)),
            prefixText: '$currency ',
            prefixStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFFA1A1AA))),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0.0;
              provider.setMonthlyBudget(provider.selectedDate, amount);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
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
            backgroundColor: const Color(0xFF121212),
            title: Text('Edit ${item.name}', style: const TextStyle(color: Colors.white)),
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
                        border: Border.all(color: const Color(0xFF27272A)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('MMM dd, yyyy').format(selectedDate),
                            style: const TextStyle(color: Colors.white),
                          ),
                          const Icon(Icons.calendar_today, size: 18, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      labelStyle: TextStyle(color: Color(0xFFA1A1AA)),
                      prefixIcon: Icon(Icons.shopping_basket, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: totalPriceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Total Price',
                      labelStyle: const TextStyle(color: Color(0xFFA1A1AA)),
                      prefixIcon: const Icon(Icons.attach_money, color: Colors.white),
                      prefixText: currency,
                    ),
                  ),
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              TextButton(
                onPressed: () {
                  provider.deleteItem(item.id);
                  Navigator.pop(context);
                },
                child: const Text('Delete', style: TextStyle(color: Color(0xFFF87171))),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFFA1A1AA))),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
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

    purchasedItems.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));

    Map<String, List<ShoppingItem>> groupedHistory = {};
    for (var item in purchasedItems) {
      final dateKey = DateFormat('yyyy-MM-dd').format(item.dateAdded);
      groupedHistory.putIfAbsent(dateKey, () => []).add(item);
    }

    final monthlyBudget = provider.totalBudget;
    final monthlySpent = provider.totalSpent;
    final remaining = provider.remainingBudget;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Ambient Top Background Glow
            Positioned(
              top: -80,
              left: MediaQuery.of(context).size.width / 2 - 120,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF27272A).withAlpha(40),
                      blurRadius: 90,
                    ),
                  ],
                ),
              ),
            ),

            Column(
              children: [
                // Top AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Avatar & Title
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                                border: Border.all(
                                  color: const Color(0xFF27272A),
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.all(3),
                              child: ClipOval(
                                child: SvgPicture.asset(
                                  'assets/logo.svg',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Flexible(
                              child: Text(
                                'ShopMind',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Right Action Controls
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Month Selector Pill
                            InkWell(
                              onTap: () => _showMonthPicker(context),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0A0A0A),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFF27272A), width: 1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      DateFormat('MMM. yyyy').format(selectedDate),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    const Icon(Icons.arrow_drop_down, size: 16, color: Color(0xFFA1A1AA)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),

                            // Share Button
                            InkWell(
                              onTap: () => PdfService.generateAndPrintPdf(
                                purchasedItems,
                                monthlyBudget,
                                monthlySpent,
                                selectedDate,
                                currency,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF0A0A0A),
                                  border: Border.all(color: const Color(0xFF27272A), width: 1),
                                ),
                                child: const Icon(
                                  Icons.share_outlined,
                                  size: 15,
                                  color: Color(0xFFA1A1AA),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Scrollable Content
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    children: [
                      // Total Budget Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A0A0A),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF27272A), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(200),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'TOTAL BUDGET',
                                  style: TextStyle(
                                    color: Color(0xFFA1A1AA),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF27272A), width: 1),
                                  ),
                                  child: Text(
                                    '$currency ACTIVE',
                                    style: const TextStyle(
                                      color: Color(0xFFA1A1AA),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Main Budget Amount
                            Text(
                              '$currency${monthlyBudget.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Metrics Grid (Remaining & Expenses)
                            Row(
                              children: [
                                // Remaining Column Card
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFF27272A), width: 1),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: const [
                                            Text(
                                              'Remaining',
                                              style: TextStyle(
                                                color: Color(0xFFA1A1AA),
                                                fontSize: 11,
                                                fontFamily: 'monospace',
                                              ),
                                            ),
                                            Text(
                                              '↑',
                                              style: TextStyle(
                                                color: Color(0xFF00D09C),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$currency${remaining.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: Color(0xFF00D09C),
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                // Expenses Column Card
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFF27272A), width: 1),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: const [
                                            Text(
                                              'Expenses',
                                              style: TextStyle(
                                                color: Color(0xFFA1A1AA),
                                                fontSize: 11,
                                                fontFamily: 'monospace',
                                              ),
                                            ),
                                            Text(
                                              '↓',
                                              style: TextStyle(
                                                color: Color(0xFFF87171),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$currency${monthlySpent.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: Color(0xFFF87171),
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // Manage Budget Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _showBudgetDialog(context),
                                icon: const Icon(
                                  Icons.account_balance_wallet_outlined,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Manage Budget',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(color: Color(0xFF27272A), width: 1),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Shopping List Shortcut Card
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ShoppingListScreen()),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A0A0A),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF27272A), width: 1),
                          ),
                          child: Row(
                            children: [
                              // Icon container
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFF27272A), width: 1),
                                ),
                                child: const Icon(
                                  Icons.shopping_cart_outlined,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Text & subtitle
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Shopping List',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${pendingItems.length} pending ${pendingItems.length == 1 ? 'item' : 'items'}',
                                          style: const TextStyle(
                                            color: Color(0xFFA1A1AA),
                                            fontSize: 11,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Counter pill & chevron
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFF27272A), width: 1),
                                    ),
                                    child: Text(
                                      '${pendingItems.length} items',
                                      style: const TextStyle(
                                        color: Color(0xFFD4D4D8),
                                        fontSize: 11,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Color(0xFF71717A),
                                    size: 18,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Transactions Grouped by Date
                      if (groupedHistory.isNotEmpty)
                        ...groupedHistory.entries.map((entry) {
                          final dateKey = entry.key;
                          final date = entry.value.first.dateAdded;
                          final dayNum = DateFormat('dd').format(date);
                          final dayName = DateFormat('EEEE').format(date);
                          final monthYear = DateFormat('MMM. yyyy').format(date);

                          double dailyTotal = entry.value.fold(
                              0.0,
                              (sum, i) =>
                                  sum + ((double.tryParse(i.price ?? '0') ?? 0) * i.quantity));

                          // Expand default: most recent group expanded
                          final isExpanded = _expandedDateGroups.contains(dateKey) ||
                              (_expandedDateGroups.isEmpty &&
                                  entry.key == groupedHistory.keys.first);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A0A0A),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF27272A), width: 1),
                            ),
                            child: Column(
                              children: [
                                // Collapsible Date Group Header
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (_expandedDateGroups.contains(dateKey)) {
                                        _expandedDateGroups.remove(dateKey);
                                      } else {
                                        _expandedDateGroups.add(dateKey);
                                      }
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              dayNum,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontFamily: 'monospace',
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  dayName,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Text(
                                                  monthYear,
                                                  style: const TextStyle(
                                                    color: Color(0xFFA1A1AA),
                                                    fontSize: 10,
                                                    fontFamily: 'monospace',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              '$currency${dailyTotal.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                color: Color(0xFFF87171),
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'monospace',
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Icon(
                                              isExpanded
                                                  ? Icons.keyboard_arrow_up
                                                  : Icons.keyboard_arrow_down,
                                              color: const Color(0xFFA1A1AA),
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Expanded Item Line Items
                                if (isExpanded) ...[
                                  const Divider(height: 1, color: Color(0xFF27272A)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: Column(
                                      children: entry.value.map((item) {
                                        final totalCost = (double.tryParse(item.price ?? '0') ?? 0) *
                                            item.quantity;
                                        final unitPrice = double.tryParse(item.price ?? '0') ?? 0;

                                        return InkWell(
                                          onTap: () => _showEditTransactionDialog(item),
                                          borderRadius: BorderRadius.circular(8),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item.name,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      '${item.quantity} × $currency${unitPrice.toStringAsFixed(2)}',
                                                      style: const TextStyle(
                                                        color: Color(0xFFA1A1AA),
                                                        fontSize: 11,
                                                        fontFamily: 'monospace',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  '$currency${totalCost.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                    fontFamily: 'monospace',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        })
                      else
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.receipt_long_outlined,
                                  size: 48,
                                  color: Color(0xFF3F3F46),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No transactions in ${DateFormat('MMM. yyyy').format(selectedDate)}',
                                  style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditItem(context),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 6,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
