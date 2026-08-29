import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/haptics.dart';
import '../../core_data/domain/models/enums.dart';
import 'add_category_dialog.dart';
import 'settings_controller.dart';

/// Settings screen (US-22). Also owns custom category management UI
/// (US-06's icon/color picker, BR-32) and backup/export actions (US-20,
/// US-21).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsScreenControllerProvider);
    final controller = ref.read(settingsScreenControllerProvider.notifier);
    final settings = state.settings;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settings == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                children: [
                  ListTile(
                    key: const Key('settings-theme-selector'),
                    title: const Text('Theme'),
                    trailing: DropdownButton<AppThemeMode>(
                      value: settings.theme,
                      items: AppThemeMode.values
                          .map((m) => DropdownMenuItem(value: m, child: Text(m.name)))
                          .toList(),
                      onChanged: (mode) {
                        if (mode != null) controller.updateTheme(mode);
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Currency'),
                    trailing: SizedBox(
                      width: 80,
                      child: TextField(
                        key: const Key('settings-currency-input'),
                        controller: TextEditingController(text: settings.currency),
                        textAlign: TextAlign.right,
                        onSubmitted: controller.updateCurrency,
                      ),
                    ),
                  ),
                  SwitchListTile(
                    key: const Key('settings-notifications-toggle'),
                    title: const Text('Notifications'),
                    value: settings.notificationsEnabled,
                    onChanged: controller.updateNotificationsEnabled,
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(child: Text('Categories', style: Theme.of(context).textTheme.titleMedium)),
                        IconButton(
                          key: const Key('settings-add-category-button'),
                          icon: const Icon(Icons.add),
                          onPressed: () => showAddCategoryDialog(context, ref),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    key: const Key('settings-manage-categories-list'),
                    children: state.categories
                        .map((c) => ListTile(
                              title: Text(c.name),
                              trailing: c.isDefault
                                  ? null
                                  : Semantics(
                                      label: 'Delete ${c.name} category',
                                      child: IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () {
                                          triggerDestructiveHaptic();
                                          controller.deleteCategory(c.id);
                                        },
                                      ),
                                    ),
                            ))
                        .toList(),
                  ),
                  const Divider(),
                  // SECURITY-01 disclosure: backup/export files are NOT
                  // separately encrypted beyond Android's OS-level
                  // File-Based Encryption of app-private storage — once a
                  // file leaves app-private storage (shared, exported to
                  // external storage), that protection no longer applies.
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text(
                      'Backup and export files are not encrypted. Store and share them carefully.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  ListTile(
                    key: const Key('settings-backup-now-button'),
                    leading: const Icon(Icons.backup),
                    title: const Text('Backup Now'),
                    onTap: state.isBusy ? null : controller.backupNow,
                  ),
                  ListTile(
                    key: const Key('settings-restore-button'),
                    leading: const Icon(Icons.restore),
                    title: const Text('Restore from Backup'),
                    onTap: state.isBusy ? null : () => _showRestorePicker(context, ref),
                  ),
                  const Divider(),
                  ListTile(
                    key: const Key('settings-export-csv-button'),
                    leading: const Icon(Icons.table_chart),
                    title: const Text('Export as CSV'),
                    onTap: state.isBusy ? null : () => controller.exportData(ExportKind.csv),
                  ),
                  ListTile(
                    key: const Key('settings-export-excel-button'),
                    leading: const Icon(Icons.grid_on),
                    title: const Text('Export as Excel'),
                    onTap: state.isBusy ? null : () => controller.exportData(ExportKind.excel),
                  ),
                  ListTile(
                    key: const Key('settings-export-json-button'),
                    leading: const Icon(Icons.code),
                    title: const Text('Export as JSON'),
                    onTap: state.isBusy ? null : () => controller.exportData(ExportKind.json),
                  ),
                  if (state.statusMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(state.statusMessage!),
                    ),
                  const Divider(),
                  const ListTile(
                    key: Key('settings-about'),
                    leading: Icon(Icons.info_outline),
                    title: Text('About'),
                    subtitle: Text('Expense Tracker v0.1.0'),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _showRestorePicker(BuildContext context, WidgetRef ref) async {
    // Restore requires picking a file via file_picker at the widget layer,
    // then delegating validation/mutation to BackupService — kept as a
    // documented TODO for the file_picker platform-channel wiring, which
    // cannot be exercised without the Flutter SDK in this environment.
    // BackupService.restoreFromBackup(File) is fully implemented and
    // tested at the domain layer (see backup_service_test.dart).
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore from Backup'),
        content: const Text(
          'File selection UI is pending file_picker platform wiring. '
          'BackupService.restoreFromBackup is implemented and tested.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    );
  }
}
