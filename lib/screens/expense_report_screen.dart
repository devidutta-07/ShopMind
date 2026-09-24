import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';

class ExpenseReportScreen extends StatelessWidget {
  const ExpenseReportScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final selectedDate = provider.selectedDate;
    final currency = provider.currencySymbol; // Use dynamic currency
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Colors
    final textColor = Theme.of(context).colorScheme.onSurface;
    final cardColor = Theme.of(context).cardColor;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    // Calculate spending for the selected month
    final targetMonth = DateFormat('yyyy-MM').format(selectedDate);
    final items = provider.items.where((i) {
      if (!i.isPurchased || i.price == null) return false;
      return DateFormat('yyyy-MM').format(i.dateAdded) == targetMonth;
    }).toList();

    final totalSpent = provider.getTotalSpentForMonth(selectedDate);

    // Calculate spending per category
    Map<String, double> categorySpending = {};
    for (var item in items) {
      final price = double.tryParse(item.price ?? '0') ?? 0.0;
      categorySpending[item.category] = (categorySpending[item.category] ?? 0) + (price * item.quantity);
    }

    // Sort categories
    final sortedCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text('Reports', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 24)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: () => _showMonthPicker(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      DateFormat('MMM. yyyy').format(selectedDate),
                      style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, size: 18, color: textColor),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Main Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Expenses by categories',
                    style: TextStyle(color: textColor.withAlpha(179), fontSize: 16),
                  ),
                  const SizedBox(height: 32),

                  // Donut Chart
                  if (totalSpent > 0)
                    SizedBox(
                      height: 200,
                      child: Stack(
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              centerSpaceRadius: 70,
                              startDegreeOffset: -90,
                              sections: sortedCategories.map((entry) {
                                return PieChartSectionData(
                                  color: _getCategoryColor(entry.key),
                                  value: entry.value,
                                  title: '',
                                  radius: 25,
                                  showTitle: false,
                                );
                              }).toList(),
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$currency${totalSpent.toStringAsFixed(0)}', // Dynamic currency
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      height: 150,
                      alignment: Alignment.center,
                      child: Text('No expenses for this month', style: TextStyle(color: textColor.withAlpha(128))),
                    ),

                  const SizedBox(height: 32),

                  // Category List
                  ...sortedCategories.map((entry) {
                    final percentage = totalSpent > 0 ? (entry.value / totalSpent) * 100 : 0.0;
                    final color = _getCategoryColor(entry.key);
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(_getCategoryIcon(entry.key), color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 16),
                          
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '$currency${entry.value.toStringAsFixed(2)}', // Dynamic currency
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: percentage / 100,
                                          backgroundColor: isDark ? Colors.white10 : Colors.grey.shade100,
                                          color: color,
                                          minHeight: 4,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${percentage.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        color: textColor.withAlpha(128),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Groceries': return const Color(0xFFE53935); 
      case 'Electronics': return const Color(0xFF8E24AA); 
      case 'Home': return const Color(0xFFFFB300); 
      case 'Personal': return const Color(0xFF1E88E5); 
      case 'Other': return const Color(0xFF43A047); 
      default: return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Groceries': return Icons.shopping_bag;
      case 'Electronics': return Icons.devices;
      case 'Home': return Icons.home;
      case 'Personal': return Icons.person;
      default: return Icons.category;
    }
  }
}
