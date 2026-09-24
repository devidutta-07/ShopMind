// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../models/shopping_item.dart';
import '../providers/app_provider.dart';

class AddEditItemScreen extends StatefulWidget {
  final ShoppingItem? item;

  const AddEditItemScreen({super.key, this.item});

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  
  String _selectedCategory = 'Groceries';
  // Default date to now, not user-selectable in this view anymore
  final DateTime _selectedDate = DateTime.now();

  // Preset Colors for New Category
  final List<Color> _presetCategoryColors = [
    const Color(0xFFE53935), // Red
    const Color(0xFF43A047), // Green
    const Color(0xFF1E88E5), // Blue
    const Color(0xFFFDD835), // Yellow
    const Color(0xFFFB8C00), // Orange
    const Color(0xFF8E24AA), // Purple
    const Color(0xFFD81B60), // Pink
    const Color(0xFF00ACC1), // Cyan
    const Color(0xFF00897B), // Teal
    const Color(0xFF6D4C41), // Brown
  ];

  // Preset Icons for New Category
  final List<IconData> _presetCategoryIcons = [
    Icons.shopping_bag,
    Icons.devices,
    Icons.home,
    Icons.person,
    Icons.fastfood,
    Icons.local_dining,
    Icons.local_cafe,
    Icons.local_gas_station,
    Icons.local_mall,
    Icons.local_hospital,
    Icons.pets,
    Icons.child_friendly,
    Icons.sports_esports,
    Icons.fitness_center,
    Icons.local_laundry_service,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _selectedCategory = widget.item?.category ?? 'Groceries';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      final newItem = ShoppingItem(
        id: widget.item?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        price: widget.item?.price,
        quantity: widget.item?.quantity ?? 1,
        isPurchased: widget.item?.isPurchased ?? false,
        category: _selectedCategory,
        dateAdded: widget.item?.dateAdded ?? _selectedDate,
      );

      Navigator.pop(context, newItem);
    }
  }

  void _deleteItem() {
    if (widget.item != null) {
      Provider.of<AppProvider>(context, listen: false).deleteItem(widget.item!.id);
      // Pop twice to go back to the home screen after deletion
      int count = 0;
      Navigator.popUntil(context, (route) => count++ == 2);
    }
  }

  void _showAddCategoryDialog() {
    final controller = TextEditingController();
    Color selectedColor = _presetCategoryColors[0];
    IconData selectedIcon = _presetCategoryIcons[0];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Custom Category'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        labelText: 'Category Name',
                        prefixIcon: Icon(Icons.category),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 24),
                    const Text('Select Color', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 50,
                      width: double.maxFinite,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _presetCategoryColors.length,
                        itemBuilder: (context, index) {
                          final color = _presetCategoryColors[index];
                          final isSelected = selectedColor == color;
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedColor = color;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
                              ),
                              child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Select Icon', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 150,
                      width: double.maxFinite,
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: _presetCategoryIcons.length,
                        itemBuilder: (context, index) {
                          final icon = _presetCategoryIcons[index];
                          final isSelected = selectedIcon == icon;
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedIcon = icon;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? Theme.of(context).colorScheme.primary.withAlpha(51) : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.withAlpha(51)),
                              ),
                              child: Icon(
                                icon,
                                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
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
                        selectedColor.toARGB32(),
                        selectedIcon.codePoint,
                      );
                      setState(() {
                        _selectedCategory = controller.text.trim();
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Black color
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('ADD CATEGORY'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isEditing = widget.item != null;
    final categories = provider.categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Item' : 'Add New Item',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name Input
              Text(
                'ITEM NAME',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Milk, Eggs, etc.',
                  prefixIcon: Icon(Icons.shopping_bag_outlined, color: Theme.of(context).colorScheme.primary),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an item name';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
              ),
              
              const SizedBox(height: 32),

              // Category Selector
              Text(
                'CATEGORY',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ...categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    final catColor = provider.getCategoryColor(category);
                    final catIcon = provider.getCategoryIcon(category);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? catColor 
                              : Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isSelected 
                              ? [
                                  BoxShadow(
                                    color: catColor.withAlpha(102),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : null,
                          border: isSelected 
                              ? null 
                              : Border.all(color: Theme.of(context).dividerColor, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              catIcon, 
                              size: 18, 
                              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface
                            ),
                            const SizedBox(width: 8),
                            Text(
                              category,
                              style: TextStyle(
                                color: isSelected 
                                    ? Colors.white 
                                    : Theme.of(context).colorScheme.onSurface.withAlpha(179),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  
                  // Add New Category Button
                  GestureDetector(
                    onTap: _showAddCategoryDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 18, color: Theme.of(context).primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            'Add New',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 50),

              // Action Buttons
              Row(
                children: [
                  if (isEditing)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _deleteItem,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('DELETE'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                          side: BorderSide(color: Theme.of(context).colorScheme.error),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                      ),
                    ),
                  if (isEditing)
                    const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _saveItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEditing ? Theme.of(context).colorScheme.primary : Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 10,
                        shadowColor: (isEditing ? Theme.of(context).colorScheme.primary : Colors.black).withAlpha(128),
                      ),
                      child: const Text(
                        'SAVE ITEM',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
