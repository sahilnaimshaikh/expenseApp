/// Describes a backup archive's contents. Written as `manifest.json`
/// inside the backup ZIP so [BackupService.restoreFromBackup] can
/// validate a file before parsing the rest of the archive (BR-29).
class BackupManifest {
  const BackupManifest({
    required this.createdAt,
    required this.appVersion,
    required this.expenseCount,
    required this.categoryCount,
    required this.budgetCount,
  });

  final DateTime createdAt;
  final String appVersion;
  final int expenseCount;
  final int categoryCount;
  final int budgetCount;

  Map<String, dynamic> toJson() => {
        'createdAt': createdAt.toIso8601String(),
        'appVersion': appVersion,
        'expenseCount': expenseCount,
        'categoryCount': categoryCount,
        'budgetCount': budgetCount,
      };

  /// Returns null (rather than throwing) on any structural mismatch — the
  /// caller (BackupService) treats a null result as "invalid backup file"
  /// and aborts the restore per BR-29, without touching Isar.
  static BackupManifest? tryParse(Map<String, dynamic> json) {
    try {
      return BackupManifest(
        createdAt: DateTime.parse(json['createdAt'] as String),
        appVersion: json['appVersion'] as String,
        expenseCount: json['expenseCount'] as int,
        categoryCount: json['categoryCount'] as int,
        budgetCount: json['budgetCount'] as int,
      );
    } catch (_) {
      return null;
    }
  }
}
