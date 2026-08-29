# Domain Entities — Unit 2: Onboarding & Expense Management

No new persistent entities — this unit consumes Expense, Category, Budget, Settings from Unit 1. It introduces one transient (non-persisted) value type:

## ExpenseInput (transient DTO)

| Field | Type | Required |
|---|---|---|
| amount | double | Yes |
| categoryId | int | Yes |
| expenseType | ExpenseType | Yes |
| date | DateTime | No (defaults to today) |
| description | String? | No |
| paymentMethod | PaymentMethod? | No |
| tags | List\<String\> | No (defaults to empty) |

**Purpose**: Carries user input from the Add/Edit Expense UI into `ExpenseService.addExpense`/`editExpense`, before it becomes a persisted `Expense` entity (with `createdAt`/`updatedAt` populated).

## OnboardingInput (transient DTO)

| Field | Type | Required |
|---|---|---|
| currency | String | Yes (defaults to "INR") |
| initialBudgetAmount | double? | No — per BR-9 below, skippable |
