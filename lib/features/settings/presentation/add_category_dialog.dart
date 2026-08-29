import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_controller.dart';

/// Custom category creation dialog (BR-32): full icon + color picker,
/// matching the default categories' styling capability.
Future<void> showAddCategoryDialog(BuildContext context, WidgetRef ref) {
  return showDialog<void>(
    context: context,
    builder: (context) => const _AddCategoryDialogContent(),
  );
}

class _AddCategoryDialogContent extends ConsumerStatefulWidget {
  const _AddCategoryDialogContent();

  @override
  ConsumerState<_AddCategoryDialogContent> createState() => _AddCategoryDialogContentState();
}

class _AddCategoryDialogContentState extends ConsumerState<_AddCategoryDialogContent> {
  final _nameController = TextEditingController();
  Color _selectedColor = Colors.blue;
  String _selectedIcon = 'category';

  static const List<String> _iconChoices = [
    'category', 'shopping_bag', 'restaurant', 'directions_car', 'home',
    'pets', 'sports_soccer', 'movie', 'book', 'flight',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Category'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('add-category-name-input'),
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            Wrap(
              key: const Key('add-category-icon-picker'),
              spacing: 8,
              children: _iconChoices
                  .map((iconName) => ChoiceChip(
                        label: Text(iconName),
                        selected: _selectedIcon == iconName,
                        onSelected: (_) => setState(() => _selectedIcon = iconName),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              key: const Key('add-category-color-picker'),
              height: 200,
              child: ColorPicker(
                pickerColor: _selectedColor,
                onColorChanged: (color) => setState(() => _selectedColor = color),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          key: const Key('add-category-save-button'),
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) return;

            final colorHex = '#${_selectedColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';
            ref.read(settingsScreenControllerProvider.notifier).addCustomCategory(
                  name: name,
                  icon: _selectedIcon,
                  color: colorHex,
                );
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
