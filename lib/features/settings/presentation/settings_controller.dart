import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../backup_export/domain/backup_export_providers.dart';
import '../../categories/domain/category_providers.dart';
import '../../core_data/data/core_data_providers.dart';
import '../../core_data/domain/models/category.dart';
import '../../core_data/domain/models/enums.dart';
import '../../core_data/domain/models/settings.dart';
import '../../onboarding/domain/onboarding_providers.dart';

class SettingsScreenState {
  const SettingsScreenState({
    this.settings,
    this.categories = const [],
    this.isBusy = false,
    this.statusMessage,
  });

  final Settings? settings;
  final List<Category> categories;
  final bool isBusy;
  final String? statusMessage;

  SettingsScreenState copyWith({
    Settings? settings,
    List<Category>? categories,
    bool? isBusy,
    String? statusMessage,
  }) {
    return SettingsScreenState(
      settings: settings ?? this.settings,
      categories: categories ?? this.categories,
      isBusy: isBusy ?? this.isBusy,
      statusMessage: statusMessage,
    );
  }
}

/// Drives the Settings screen (US-22) — theme/currency/notifications,
/// custom category management, backup/restore, and export.
class SettingsScreenController extends Notifier<SettingsScreenState> {
  @override
  SettingsScreenState build() {
    Future.microtask(load);
    return const SettingsScreenState();
  }

  Future<void> load() async {
    final settingsService = await ref.read(settingsServiceProvider.future);
    final categoryRepository = await ref.read(categoryRepositoryProvider.future);

    final settings = await settingsService.getSettings();
    final categories = await categoryRepository.getAll();

    state = state.copyWith(settings: settings, categories: categories);
  }

  Future<void> updateTheme(AppThemeMode mode) async {
    final service = await ref.read(settingsServiceProvider.future);
    await service.updateTheme(mode);
    await load();
  }

  Future<void> updateCurrency(String currency) async {
    final service = await ref.read(settingsServiceProvider.future);
    await service.updateCurrency(currency);
    await load();
  }

  Future<void> updateNotificationsEnabled(bool enabled) async {
    final service = await ref.read(settingsServiceProvider.future);
    await service.updateNotificationPreferences(enabled: enabled);
    await load();
  }

  Future<void> addCustomCategory({required String name, required String icon, required String color}) async {
    final service = await ref.read(categoryServiceProvider.future);
    try {
      await service.createCustomCategory(name: name, icon: icon, color: color);
      await load();
    } catch (e) {
      state = state.copyWith(statusMessage: 'Could not add category: $e');
    }
  }

  Future<void> deleteCategory(int id) async {
    final service = await ref.read(categoryServiceProvider.future);
    try {
      await service.deleteCategory(id);
      await load();
    } catch (e) {
      state = state.copyWith(statusMessage: 'Could not delete category: $e');
    }
  }

  Future<void> backupNow() async {
    state = state.copyWith(isBusy: true, statusMessage: null);
    try {
      final backupService = await ref.read(backupServiceProvider.future);
      final file = await backupService.createManualBackup(null);
      state = state.copyWith(isBusy: false, statusMessage: 'Backup saved: ${file.path}');
    } catch (e) {
      state = state.copyWith(isBusy: false, statusMessage: "Couldn't create a backup. Please try again.");
    }
  }

  Future<void> exportData(ExportKind kind) async {
    state = state.copyWith(isBusy: true, statusMessage: null);
    try {
      final exportService = await ref.read(exportServiceProvider.future);
      final file = switch (kind) {
        ExportKind.csv => await exportService.exportToCsv(null),
        ExportKind.excel => await exportService.exportToExcel(null),
        ExportKind.json => await exportService.exportToJson(null),
      };
      state = state.copyWith(isBusy: false, statusMessage: 'Exported: ${file.path}');
    } catch (e) {
      state = state.copyWith(isBusy: false, statusMessage: "Couldn't export your data. Please try again.");
    }
  }
}

enum ExportKind { csv, excel, json }

final NotifierProvider<SettingsScreenController, SettingsScreenState> settingsScreenControllerProvider =
    NotifierProvider<SettingsScreenController, SettingsScreenState>(SettingsScreenController.new);
