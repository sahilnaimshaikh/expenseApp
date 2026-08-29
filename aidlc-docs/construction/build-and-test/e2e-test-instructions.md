# End-to-End Test Instructions — Expense Tracker

## Purpose
Validate complete user workflows spanning multiple screens/units, matching the acceptance criteria in [stories.md](../../inception/user-stories/stories.md). Use `integration_test` (Flutter's on-device/emulator E2E framework) rather than `flutter_test`'s widget-test harness, since these flows exercise real navigation and persistence across the whole app.

## Setup
```bash
flutter pub add --dev integration_test --sdk=flutter
mkdir integration_test
```

## Golden Path Flows

### Flow 1: First Launch → Onboarding → Add First Expense (US-01, US-02)
1. Fresh install / cleared app data.
2. Launch app → redirected to `/onboarding`.
3. Enter currency "INR" (or accept default), enter an initial budget of 20000, tap "Get Started".
4. Verify redirect to Dashboard (`/`), showing ₹0 spent of ₹20,000.
5. Tap the Dashboard's quick-add FAB → navigates to `/expenses/add`.
6. Enter amount 250, select "Food" category, leave type as Personal, tap Save.
7. Verify navigation back and the Dashboard now shows ₹250 spent.
8. **Acceptance criteria covered**: US-01 AC1/AC2, US-02 AC1.

### Flow 2: Cross a Budget Threshold and Receive a Notification (US-11, US-12)
1. From Flow 1's state (₹20,000 budget), add expenses totaling ₹10,050 (crossing 50%).
2. Verify (via a test-only notification spy, since real notification UI can't be asserted directly in `integration_test`) that `NotificationService.notifyThresholdCrossed` fired once for threshold 50.
3. Add another ₹100 expense (still above 50%, not yet 75%).
4. Verify no second notification for threshold 50 (BR-14).
5. **Acceptance criteria covered**: US-12 AC1, AC2.

### Flow 3: Search, Filter, and Sort the Expense List (US-07, US-08, US-09)
1. Seed 5+ expenses across 2 categories, 2 expense types, a range of amounts and dates.
2. Navigate to Expenses tab.
3. Type a search term matching one expense's description → verify only matching row(s) shown.
4. Clear search; open the filter sheet; filter by category + amount range → verify AND-combined results.
5. Clear filter; select "Highest Amount" sort → verify descending order.
6. **Acceptance criteria covered**: US-07 AC1, US-08 AC1/AC2, US-09 AC1.

### Flow 4: View All 6 Reports (US-14 to US-19)
1. From Flow 3's seeded data, navigate to the Reports tab.
2. Tap through all 6 tabs (Monthly, Category, Personal vs Home, Top Categories, Comparison, Utilization).
3. Verify each renders without error and shows non-empty data.
4. **Acceptance criteria covered**: US-14 through US-19, all AC1s.

### Flow 5: Backup, Wipe, and Restore (US-20)
1. From Flow 4's state, go to Settings tab, tap "Backup Now".
2. Verify success message with a file path.
3. **Manually** clear app data (simulating device loss) or use a fresh Isar instance in the test harness.
4. Trigger `BackupService.restoreFromBackup` with the file from step 2 (via a test-only hook, since the UI's restore file-picker is not yet wired — see code-summary.md's known gap).
5. Verify all expenses, categories, budgets, and settings match pre-wipe state.
6. **Acceptance criteria covered**: US-20 AC2, AC3.

### Flow 6: Export to All 3 Formats (US-21)
1. From Settings, tap Export CSV, Export Excel, Export JSON in turn.
2. Verify each produces a success message with a file path, and each file is non-empty and parses correctly in its format.
3. **Acceptance criteria covered**: US-21 AC1.

### Flow 7: Edit a Custom Category and Verify Reassignment (US-06)
1. Create a custom category "Hobby" with an icon/color.
2. Add an expense under "Hobby".
3. Delete the "Hobby" category from Settings.
4. Verify the expense now shows under "Others" (BR-3).
5. **Acceptance criteria covered**: US-06, all BR-2/BR-3 scenarios.

## Run E2E Tests
```bash
flutter test integration_test/ -d <device_id>
```

## Known Gaps
- Flow 5's restore step needs a test-only hook since the production UI's file-picker wiring is deferred (see Unit 6's code-summary.md). Write the E2E test against `BackupService` directly for now; update once file_picker is wired.
- No E2E test files currently exist in this repository — this document specifies the flows to author.
