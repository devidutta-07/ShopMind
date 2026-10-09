import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shopping_item.dart';
import '../providers/app_provider.dart';
import 'add_edit_item_screen.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
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

  void _handleItemCheck(ShoppingItem item, bool? value) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final currency = provider.currencySymbol;

    if (value == true) {
      final totalPriceController = TextEditingController(text: item.price ?? '');
      final quantityController = TextEditingController(text: item.quantity.toString());

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final pendingItems = provider.items.where((i) => !i.isPurchased).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Shopping List', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: pendingItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFF242B26),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.checklist_rtl, size: 48, color: Color(0xFFDBE6D5)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your shopping list is empty!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap + to add new items to buy.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendingItems.length,
              itemBuilder: (context, index) {
                final item = pendingItems[index];
                final catColor = provider.getCategoryColor(item.category);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: const Color(0xFF0A0A0A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFF27272A), width: 1),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Checkbox(
                      value: false,
                      onChanged: (val) => _handleItemCheck(item, true),
                      shape: const CircleBorder(),
                      activeColor: const Color(0xFF9C27B0),
                    ),
                    title: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
                    subtitle: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: catColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(item.category, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.grey, size: 20),
                      onPressed: () => _navigateToAddEditItem(context, item),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditItem(context),
        backgroundColor: const Color(0xFF9C27B0),
        child: const Icon(Icons.add),
      ),
    );
  }
}
