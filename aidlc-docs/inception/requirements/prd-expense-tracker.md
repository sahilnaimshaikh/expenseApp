# Product Requirements Document (PRD)

# Expense Tracker

**Version**: 1.0
**Platform**: Android (Flutter)
**Database**: Isar (Local Storage)
**Architecture**: Offline First
**Target User**: Single User (Personal Use)

## 1. Executive Summary

Expense Tracker is a premium, offline-first personal finance application designed for individuals who want complete control over their expenses without relying on cloud services or subscriptions.

The application focuses on simplicity, speed, and insightful financial reporting while ensuring that all user data remains on the user's device. The app will allow users to record expenses, monitor monthly budgets, receive budget notifications, and visualize spending trends through interactive dashboards and reports.

The application is intended to feel modern, elegant, and effortless to use, with the goal that adding a new expense should take less than 10 seconds.

## 2. Objectives

The primary objectives of the application are:
- Record expenses quickly and efficiently.
- Organize expenses into categories.
- Separate expenses into Personal and Home ledgers.
- Track monthly budgets.
- Notify users when budget limits are approaching or exceeded.
- Provide detailed monthly reports and analytics.
- Offer powerful filtering and search capabilities.
- Operate completely offline.
- Provide backup and restore functionality without requiring cloud services.

## 3. Product Vision

The application should not simply act as an expense recorder. Instead, it should function as a personal financial dashboard that enables the user to understand:
- Where money is being spent
- Which categories consume the largest portion of income
- Monthly spending trends
- Budget utilization
- Historical spending behavior

The application should emphasize clarity, speed, and elegant presentation.

## 4. Target Audience

This application is designed primarily for:
- Individuals managing personal finances
- Families tracking household expenses
- Users who prefer complete privacy
- Users who want an offline-first application
- Users who do not wish to maintain cloud accounts

## 5. Functional Requirements

### 5.1 Expense Management

The application shall allow users to create, edit, delete, and search expenses.

Each expense shall contain:

| Field | Required | Description |
|---|---|---|
| Amount | Yes | Expense amount |
| Category | Yes | Expense category |
| Expense Type | Yes | Personal or Home |
| Description | Optional | User notes |
| Date | Yes | Expense date |
| Payment Method | Optional | Cash, UPI, Debit Card, Credit Card, Bank Transfer |
| Tags | Optional | Custom searchable tags |
| Created Time | Auto | System generated |
| Updated Time | Auto | System generated |

**Default Categories**
- Food
- Groceries
- Fuel
- Utilities
- Shopping
- Medical
- Education
- Travel
- Entertainment
- Investment
- Rent
- Gifts
- Others

The application shall also allow users to create custom categories.

### 5.2 Expense Types

Every expense must belong to one of the following ledgers:
- Personal
- Home

Reports, budgets, and dashboards shall support:
- Personal only
- Home only
- Combined view

### 5.3 Budget Management

The application shall support monthly budgeting.

Each month shall have:
- Monthly Budget Amount
- Amount Spent
- Remaining Amount
- Percentage Used

Users shall be able to configure budget notifications.

Supported notification thresholds:
- 50%
- 75%
- 90%
- 100%

When spending exceeds the configured threshold, the application shall generate a local notification.

Future versions may support category-wise budgets.

### 5.4 Search & Filtering

The application shall support searching by:
- Description
- Category
- Tags
- Payment Method

Filters shall include:
- Month
- Year
- Date Range
- Category
- Expense Type
- Payment Method
- Amount Range

Sorting options:
- Newest First
- Oldest First
- Highest Amount
- Lowest Amount

### 5.5 Reports

The application shall provide comprehensive reporting.

- **Monthly Spending**: Display total expenses for each month.
- **Category Analysis**: Display expenses grouped by category.
- **Personal vs Home**: Display spending comparison between Personal and Home expenses.
- **Top Spending Categories**: Rank categories by expenditure.
- **Monthly Comparison**: Compare current month's spending with previous months.
- **Budget Utilization**: Display percentage of monthly budget consumed.

### 5.6 Dashboard

The dashboard shall provide an overview of the user's financial status.

The dashboard shall include:
- Current Month
- Monthly Budget
- Total Spent
- Remaining Budget
- Budget Progress Bar
- Personal vs Home Summary
- Category Breakdown
- Recent Expenses
- Monthly Trend Graph

The dashboard should be the first screen shown when opening the application.

### 5.7 Notifications

Local notifications shall be generated for:
- Budget threshold reached
- Budget exceeded
- End-of-month financial summary (optional)

Notifications must work completely offline.

### 5.8 Backup & Restore

The application shall support:
- Backup database
- Restore database

**Backup format**: ZIP Archive

**Backup contents**:
- Database
- Settings
- Categories
- Receipt Images (Future)

**Export formats**:
- CSV
- Excel
- JSON

## 6. Non-Functional Requirements

The application must:
- Work completely offline
- Launch within 2 seconds
- Handle 500,000+ expense records efficiently
- Consume minimal battery
- Support Android Dark Mode
- Be responsive on phones and tablets
- Maintain smooth animations at 60 FPS

## 7. User Interface Design

**Design Philosophy** — the interface should feel:
- Premium
- Modern
- Minimal
- Fast
- Clean

Avoid unnecessary visual clutter. The application should prioritize readability and usability.

## 8. Navigation Structure

```
+----------------------------------------------------+
  Dashboard
  Expenses
  Add Expense
  Reports
  Settings
+----------------------------------------------------+
```

## 9. Screen Specifications

### 9.1 Dashboard

**Purpose**: Provide a complete financial overview.

**Components**:
- Greeting
- Current Month
- Monthly Budget Card
- Budget Progress Indicator
- Personal vs Home Summary
- Category Breakdown Chart
- Monthly Spending Graph
- Recent Expenses
- Quick Add Expense Button

### 9.2 Add Expense

The Add Expense screen should require minimal user interaction.

**Layout**:
- Amount (Large Numeric Input)
- Expense Type (Personal / Home)
- Category Dropdown
- Description
- Payment Method
- Date Picker
- Tags
- Save Button

Expense creation should take fewer than 10 seconds.

### 9.3 Expense List

Display expenses grouped by date.

Each expense card shall display:
- Amount
- Category
- Description
- Expense Type
- Date
- Payment Method

Supported interactions:
- Swipe Left → Delete
- Swipe Right → Edit
- Long Press → Multi Select

### 9.4 Reports

Charts shall include:
- Monthly Spending
- Category Pie Chart
- Personal vs Home Comparison
- Top Categories
- Budget Utilization

All charts should animate smoothly.

### 9.5 Budget Screen

Display:
- Monthly Budget
- Amount Spent
- Remaining Budget
- Budget Progress
- Notification Settings
- Budget History

### 9.6 Settings

Settings shall include:
- Theme (Dark / Light / System)
- Currency
- Notification Preferences
- Backup & Restore
- Export Data
- About

## 10. Database Design

**Expense Collection**

| Field | Type |
|---|---|
| id | Integer |
| amount | Double |
| category | String |
| expenseType | String |
| description | String |
| paymentMethod | String |
| tags | List |
| date | DateTime |
| createdAt | DateTime |
| updatedAt | DateTime |

**Budget Collection**

| Field | Type |
|---|---|
| month | Integer |
| year | Integer |
| budgetAmount | Double |
| notify50 | Boolean |
| notify75 | Boolean |
| notify90 | Boolean |
| notify100 | Boolean |

**Category Collection**

| Field | Type |
|---|---|
| id | Integer |
| name | String |
| icon | String |
| color | String |

**Settings Collection**

| Field | Type |
|---|---|
| theme | String |
| currency | String |
| notifications | Boolean |
| backupLocation | String |

## 11. User Experience Guidelines

The application shall emphasize speed. Guidelines include:
- One-tap navigation where possible.
- Large touch targets.
- Smooth page transitions.
- Animated charts.
- Animated progress indicators.
- Haptic feedback for destructive actions.
- Instant search.
- Fast scrolling.
- Consistent spacing.
- Rounded Material 3 cards.
- Elegant typography.

## 12. Technical Architecture

| Component | Technology |
|---|---|
| Frontend | Flutter |
| Language | Dart |
| Local Database | Isar |
| Charts | FL Chart |
| State Management | Riverpod |
| Local Notifications | flutter_local_notifications |
| Routing | Go Router |
| Local Storage | Isar + File System |

No backend services shall be required.
No cloud infrastructure shall be required.
No user authentication shall be required.

## 13. Future Roadmap (Version 2)

- Income Tracking
- Multiple Wallets
- Bank Accounts
- Credit Cards
- Recurring Expenses
- Receipt Image Attachments
- Financial Goals
- Savings Tracker
- Investment Tracking
- Subscription Management
- PIN Lock
- Biometric Authentication
- Home Screen Widgets
- Optional Cloud Sync

## 14. Development Roadmap

**Phase 1 – Minimum Viable Product (MVP)**
- Project setup
- Isar database integration
- Expense CRUD operations
- Category management
- Personal/Home ledgers
- Dashboard
- Monthly budgets
- Expense listing

**Phase 2 – Analytics**
- Reports
- Charts
- Search
- Filters
- Sorting
- Budget notifications

**Phase 3 – Productivity**
- Backup & Restore
- Export to CSV, Excel, JSON
- Custom categories
- Payment methods
- Tags
- Settings

**Phase 4 – Premium Experience**
- UI polish
- Animations
- Performance optimization
- Material 3 enhancements
- Accessibility improvements

## 15. Success Criteria

The application shall be considered successful when it achieves the following goals:
- Users can record an expense in under a second. *(Note: appears inconsistent with the 10-second target stated elsewhere in this document — flagged for clarification.)*
- Monthly spending is visible immediately upon opening the app.
- Budget status is always visible and understandable.
- Reports provide meaningful insights into spending habits.
- All data remains securely stored on the device without requiring internet connectivity.
- The interface delivers a modern, smooth, and premium user experience while maintaining excellent performance on Android devices.
