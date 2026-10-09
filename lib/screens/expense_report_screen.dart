import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';

class ExpenseReportScreen extends StatefulWidget {
  const ExpenseReportScreen({super.key});

  @override
  State<ExpenseReportScreen> createState() => _ExpenseReportScreenState();
}

class _ExpenseReportScreenState extends State<ExpenseReportScreen> {
  void _showMonthPicker(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    DateTime tempDate = provider.selectedDate;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A0A0A),
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
                              color: isSelected ? const Color(0xFFE4907A).withAlpha(51) : null,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              DateFormat('MMM').format(monthDate),
                              style: TextStyle(
                                color: isSelected ? const Color(0xFFE4907A) : Colors.white70,
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

  String _formatCompactCurrency(double amount, String symbol) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K $symbol';
    }
    return '${amount.toStringAsFixed(0)} $symbol';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final selectedDate = provider.selectedDate;
    final currency = provider.currencySymbol;

    // Palette matching design
    const cardBg = Color(0xFF0A0A0A);
    const cardBorder = Color(0xFF27272A);
    const accentCoral = Color(0xFFE4907A);
    const mutedText = Color(0xFF8F7D79);

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
      categorySpending[item.category] =
          (categorySpending[item.category] ?? 0) + (price * item.quantity);
    }

    final sortedCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text(
          'Reports',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 26,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: () => _showMonthPicker(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2320),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      DateFormat('MMM. yyyy').format(selectedDate),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, size: 18, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Card 1: Expenses by categories
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: cardBorder, width: 1),
              ),
              child: Column(
                children: [
                  const Text(
                    'Expenses by categories',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Circular Donut Chart
                  if (totalSpent > 0)
                    SizedBox(
                      height: 210,
                      width: 210,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              centerSpaceRadius: 68,
                              startDegreeOffset: -90,
                              sections: sortedCategories.isNotEmpty
                                  ? sortedCategories.map((entry) {
                                      final catColor = provider.getCategoryColor(entry.key);
                                      return PieChartSectionData(
                                        color: catColor,
                                        value: entry.value,
                                        title: '',
                                        radius: 22,
                                        showTitle: false,
                                      );
                                    }).toList()
                                  : [
                                      PieChartSectionData(
                                        color: accentCoral,
                                        value: 1,
                                        title: '',
                                        radius: 22,
                                        showTitle: false,
                                      ),
                                    ],
                            ),
                          ),
                          Container(
                            width: 84,
                            height: 84,
                            decoration: const BoxDecoration(
                              color: Color(0xFF191312),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _formatCompactCurrency(totalSpent, currency),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      height: 150,
                      alignment: Alignment.center,
                      child: const Text(
                        'No expenses for this month',
                        style: TextStyle(color: mutedText, fontSize: 15),
                      ),
                    ),

                  const SizedBox(height: 28),

                  // Category Breakdown List
                  if (sortedCategories.isNotEmpty)
                    ...sortedCategories.map((entry) {
                      final percentage = totalSpent > 0 ? (entry.value / totalSpent) * 100 : 0.0;
                      final catColor = provider.getCategoryColor(entry.key);
                      final catIcon = provider.getCategoryIcon(entry.key);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: catColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(catIcon, color: Colors.white, size: 18),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${entry.value.toStringAsFixed(2)} $currency',
                                  style: TextStyle(
                                    color: catColor,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const SizedBox(width: 48),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: (percentage / 100).clamp(0.0, 1.0),
                                      backgroundColor: const Color(0xFF352926),
                                      color: catColor,
                                      minHeight: 3.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${percentage.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    color: mutedText,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    })
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Card 2: Monthly Expenses
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: cardBorder, width: 1),
              ),
              child: Column(
                children: [
                  const Text(
                    'Monthly expenses',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Monthly Ledger List (Jan to Dec in chronological order)
                  Column(
                    children: List.generate(12, (index) {
                      final monthIndex = index + 1; // 1 to 12
                      final date = DateTime(selectedDate.year, monthIndex);
                      final monthName = DateFormat('MMM').format(date); // Jan, Feb, Mar...
                      final spent = provider.getTotalSpentForMonth(date);
                      final isCurrent = monthIndex == selectedDate.month;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              monthName,
                              style: TextStyle(
                                color: isCurrent ? Colors.white : Colors.white60,
                                fontSize: 15,
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            Text(
                              '${spent.toStringAsFixed(2)} $currency',
                              style: TextStyle(
                                color: spent > 0 ? accentCoral : mutedText,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
