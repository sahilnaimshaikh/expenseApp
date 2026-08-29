# Domain Entities — Unit 1: Core Data & Categories

Technology-agnostic entity definitions. Isar-specific annotations are noted but the model itself is framework-independent.

## Expense

| Field | Type | Required | Notes |
|---|---|---|---|
| id | int | Auto (Isar autoIncrement) | Primary key |
| amount | double | Yes | Stored as Double per PRD; all summation/percentage math uses a decimal-safe library, converting to Double only at the Isar read/write boundary (Q1) |
| categoryId | int | Yes | Foreign key to Category.id |
| expenseType | enum (`Personal`, `Home`) | Yes | Ledger scope |
| description | String? | No | User notes |
| paymentMethod | enum? (`Cash`, `UPI`, `DebitCard`, `CreditCard`, `BankTransfer`) | No | |
| tags | List\<String\> | No | Custom searchable tags, defaults to empty list |
| date | DateTime | Yes | Expense date (user-editable, defaults to today on creation) |
| createdAt | DateTime | Auto | Set once on creation, never modified |
| updatedAt | DateTime | Auto | Set on creation, refreshed on every update |

**Invariants**:
- `amount > 0` always (enforced by ExpenseService before persistence — see [business-rules.md](business-rules.md))
- `categoryId` must reference an existing Category at write time
- `createdAt <= updatedAt` always

## Budget

| Field | Type | Required | Notes |
|---|---|---|---|
| id | int | Auto | Primary key |
| month | int | Yes | 1-12 |
| year | int | Yes | e.g., 2026 |
| ledgerScope | enum (`Combined`, `Personal`, `Home`) | Yes | Q5: one row per scope per month, not parallel nullable fields |
| budgetAmount | double | Yes | Same precision approach as Expense.amount (Q1) |
| notify50 | bool | Yes | Default true on creation |
| notify75 | bool | Yes | Default true |
| notify90 | bool | Yes | Default true |
| notify100 | bool | Yes | Default true |

**Invariants**:
- `budgetAmount > 0` always
- Uniqueness: at most one Budget row per `(month, year, ledgerScope)` combination
- **Combined-mode rule** (requirements.md FR-3.2): when the user is in combined mode, only a `Combined`-scope row exists for that month — no `Personal`/`Home` rows. When the user opts into per-ledger budgets, `Personal` and `Home` rows exist and no `Combined` row is created for that month. This mode switch is a BudgetService-level concern (Unit 3), not enforced by the schema itself — Unit 1 only defines the storage shape.

## Category

| Field | Type | Required | Notes |
|---|---|---|---|
| id | int | Auto | Primary key |
| name | String | Yes | Unique, case-insensitive (Q7 invariant) |
| icon | String | Yes | Icon identifier (e.g., Material icon name or asset path) |
| color | String | Yes | Color value (e.g., hex string) |
| isDefault | bool | Yes | Q2: true for the 13 PRD-seeded categories, false for user-created ones |

**Invariants**:
- `name` uniqueness is case-insensitive (`"Food"` and `"food"` are considered duplicates)
- Rows where `isDefault == true` cannot be deleted or renamed (enforced by CategoryService — see business-rules.md); `isDefault` is never set to `true` by user action, only by the seeding process

## Settings

| Field | Type | Required | Notes |
|---|---|---|---|
| id | int | Fixed (always `1`) | Q4: enforced singleton — SettingsRepository never creates a second row |
| theme | enum (`Dark`, `Light`, `System`) | Yes | Default `System` |
| currency | String | Yes | Default `"INR"` (requirements.md decision) |
| notificationsEnabled | bool | Yes | Default `true` |
| backupLocation | String? | No | User-chosen path for manual backups; null until first manual backup |
| onboardingComplete | bool | Yes | Default `false`; drives US-01 first-launch routing |

**Invariants**:
- Exactly one Settings row ever exists, with `id == 1`

## Entity Relationships

```
Category (1) <---- (many) Expense
   isDefault flag        categoryId FK

Budget (independent per month+scope; no direct FK to Expense —
        BudgetService in Unit 3 computes spend by querying
        Expense rows within the relevant date range + ledgerScope)

Settings (singleton, no relationships to other entities)
```

**Note**: Budget does not hold a foreign key to Expense. Spend totals are always computed on-demand by summing matching Expense rows (per month/year/ledgerScope) — this is a deliberate choice so that editing/deleting an Expense automatically reflects in Budget calculations without needing to maintain a denormalized running total (avoids a whole class of data-consistency bugs). This is documented here because it affects Unit 3's BudgetService design directly.
