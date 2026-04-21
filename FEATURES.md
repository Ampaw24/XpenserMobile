# Xpenser — Feature Roadmap & Implementation Guide

> This document covers every feature needed to make Xpenser a complete, production-ready expense tracking app. Each section describes what the feature does, what screens/components to build, and the data it needs.

---

## App Flow (Current vs Target)

**Current broken flow:**
```
Splash (unused) → Onboarding → Login → DEAD END
```

**Target flow:**
```
Splash
  └── First launch?  ──YES──► Onboarding ──► Register / Login
                     ──NO───► Login (or straight to Home if session exists)

Login / Register
  └──► Home (AppShell)
         ├── Dashboard (Home tab)
         ├── Expenses tab
         ├── Tools tab  (Currency + Tax)
         └── Settings tab
```

---

## 1. Authentication

### 1.1 Splash Screen → App Entry Gate
**What it does:** Decides where to send the user on cold start.

- Show logo for 2–3 seconds
- Check if a session token exists (shared preferences / secure storage)
- If session exists → go to `AppShell`
- If first launch → go to `OnboardingScreen`
- If returning but logged out → go to `LoginScreen`

**Components needed:**
- `SplashViewModel` with `checkAuthState()` method
- `SharedPreferences` or `flutter_secure_storage` for token storage

---

### 1.2 Login Screen
**What it does:** Authenticates an existing user.

- Email + password fields with inline validation
  - Email: must be valid format
  - Password: minimum 6 characters
- Show/hide password toggle button
- "Sign In" button → calls auth service → navigates to `AppShell`
- "Forgot Password?" link → navigates to `ForgotPasswordScreen`
- "Don't have an account? Sign Up" → navigates to `RegisterScreen`
- Loading state while auth request is in flight
- Error snackbar on failure (wrong credentials, no network)
- Google sign-in (wire up the existing UI button)

**Data needed:** `AuthViewModel` with `signIn(email, password)` method, `isLoading` state, `errorMessage` state.

---

### 1.3 Register Screen
**What it does:** Creates a new user account. Currently missing entirely.

**Fields:**
- Full name
- Email
- Password
- Confirm password
- "Create Account" button

**Validation:**
- All fields required
- Email format check
- Passwords must match
- Password strength indicator (optional but nice)

**Data needed:** `AuthViewModel.signUp(name, email, password)` method.

---

### 1.4 Forgot Password Screen
**What it does:** Sends a password reset email.

- Single email field
- "Send Reset Link" button
- Success message shown after submission

---

## 2. Dashboard (Home Tab)

This is the most important screen — the user's financial overview at a glance. Currently a placeholder.

### 2.1 Balance Summary Card
**What it shows:**
- Total balance (income − expenses) for the current month
- Total income this month
- Total expenses this month

**Design:** A prominent card at the top of the Home screen with a colored gradient background. Tapping it could expand to a monthly breakdown.

---

### 2.2 Recent Transactions List
**What it shows:** The last 5–10 expense entries with:
- Category icon + color
- Title/description
- Date
- Amount (negative for expenses, positive for income)

**Design:** Card-style list items below the balance card. A "See All" link navigates to the full Expenses tab.

---

### 2.3 Spending by Category — Chart
**What it shows:** A donut/pie chart breaking down where money went this month by category (Food, Transport, Shopping, etc.).

> `charts.svg` asset already exists in `assets/images/` — use `fl_chart` or `syncfusion_flutter_gauges` (already installed) for the actual chart widget.

**Design:** Shown below the recent transactions. Each slice has a category color and a legend below it.

---

### 2.4 Budget Progress Bars
**What it shows:** If budgets are set (see Feature 5), show a mini progress bar per category showing spend vs. budget limit.

**Design:** Horizontal bars with category name, amount spent, and percentage filled. Red fill when over budget.

---

## 3. Expense Management (Core Feature — Entirely Missing)

This is the heart of the app. Nothing here exists yet.

### 3.1 Add / Edit Expense Screen
**Fields:**
- Amount (number input, required)
- Category (picker: Food, Transport, Shopping, Health, Entertainment, Bills, Other)
- Title / Description (text, optional)
- Date (date picker, defaults to today)
- Payment method (Cash, Card, Transfer — optional)
- Receipt photo (camera / gallery — optional, advanced)
- Notes (optional)

**Behavior:**
- "Save" button validates and saves to local DB
- Can be opened in "edit mode" by passing an existing expense
- Pre-fills all fields when editing

---

### 3.2 Expense List Screen (Expenses Tab)
**What it shows:** A filterable, scrollable list of all recorded expenses.

**Features:**
- Filter by: date range, category, payment method
- Sort by: date (newest first), amount (highest first)
- Search bar to find by title/description
- Swipe-to-delete with undo snackbar
- Tap to open edit screen
- Grouped by date (Today, Yesterday, This Week, etc.)
- Empty state illustration when no expenses exist

---

### 3.3 Expense Model
```
ExpenseModel {
  id          : String   (UUID)
  title       : String
  amount      : double
  category    : ExpenseCategory (enum)
  date        : DateTime
  paymentMethod: PaymentMethod (enum)
  notes       : String?
}
```

**Categories enum:** Food, Transport, Shopping, Health, Entertainment, Bills, Salary, Other

---

### 3.4 Expense ViewModel
- `addExpense(ExpenseModel)`
- `updateExpense(ExpenseModel)`
- `deleteExpense(String id)`
- `getExpensesByMonth(DateTime month)` → `List<ExpenseModel>`
- `getTotalByCategory(ExpenseCategory, DateTime month)` → `double`
- `getMonthlyTotal(DateTime month)` → `double`

---

### 3.5 Data Persistence
All expenses must survive app restarts. Recommended options:

| Option | Package | Best for |
|--------|---------|----------|
| **Hive** | `hive_flutter` | Fast, offline-first, simple |
| **Isar** | `isar` | Typed queries, relations, reactive |
| **SQLite** | `sqflite` | Familiar SQL, good for complex queries |

Recommended: **Hive** for simplicity and speed at this stage.

---

## 4. Income Tracking

The flip side of expenses. Users need to log income to compute a real balance.

### 4.1 Add Income Entry
Same form as Add Expense but with income-specific categories:
- Salary, Freelance, Investment, Gift, Other

**Integration:** Income entries feed into the Dashboard balance card.

---

## 5. Budget Planner (Mentioned in Feature Cards — Not Built)

### 5.1 Set Monthly Budget per Category
**What it does:** User sets a spending cap per category per month.

**Screen: Budget Setup**
- List of categories with a field to set the monthly limit
- Can leave a category unlimited
- "Save" button persists the limits

---

### 5.2 Budget Progress View
**What it shows:** For each category with a budget set:
- Category name + icon
- Amount spent vs. limit (e.g. "$320 of $500")
- Color-coded progress bar (green → yellow → red as limit approaches)
- "Over budget" badge when exceeded

**Notification trigger:** Alert user when they reach 80% of a budget (optional, advanced).

---

## 6. Currency Converter (Improve Existing)

### 6.1 Real-Time Exchange Rates
Current implementation uses hardcoded mock rates for only USD and EUR as source currencies. All other source currencies return the input amount unchanged.

**Fix:** Integrate a free exchange rate API.

Recommended: [ExchangeRate-API](https://www.exchangerate-api.com/) or [Open Exchange Rates](https://openexchangerates.org/) — both have free tiers.

**Flow:**
- On screen open, fetch latest rates (or use cached rates < 1 hour old)
- Show a loading indicator while fetching
- Show "rates last updated: X minutes ago" timestamp
- Handle no-internet gracefully with the cached rates

---

### 6.2 Swap Button
Add a ⇄ swap icon button between the From and To dropdowns. Tapping it swaps the two currencies and recalculates.

---

### 6.3 Expand Supported Currencies
Currently 8. Expand to 30+ major currencies including:
`NGN, GHS, ZAR, KES, AED, INR, BRL, MXN, SEK, NOK, SGD, HKD, KRW, TRY, RUB`

---

### 6.4 Conversion History
Keep a small list (last 10) of recent conversions shown below the converter card. Each item shows: amount, from→to, result, timestamp.

---

## 7. Tax Calculator (Improve Existing)

### 7.1 Complete All Filing Statuses
Currently only "Single" uses real 2023 US brackets. The other 3 statuses use a flat 20%.

**Fix:** Add accurate bracket logic for:
- Married Filing Jointly
- Married Filing Separately
- Head of Household

---

### 7.2 Effective Tax Rate Display
Add a third result card showing the **effective tax rate** (tax ÷ income × 100). This is a common and useful number that users want to see.

---

### 7.3 Country / Tax System Selector
Allow the user to pick a country/system — not just US.

Suggested initial set: US, UK (PAYE), Nigeria (PAYE), Ghana (PAYE).
Each has its own bracket table in the `TaxViewModel`.

---

### 7.4 Tax Breakdown Table
Show a breakdown of how tax was calculated — each bracket, the amount that fell in it, and the tax it generated. Helps users understand the result.

---

## 8. Settings (Make Them Functional)

All 6 settings items currently have empty `onTap: () {}`.

### 8.1 Profile Screen
- Display name, email
- Edit name button
- Profile picture (pick from gallery)
- Change password option

### 8.2 Appearance — Dark Mode Toggle
- Toggle switch between light and dark theme
- `AppTheme.dark` already exists in `core/utils/theme/themes.dart` — just needs to be applied
- Store preference in `SharedPreferences`
- `ThemeViewModel` with a `StateProvider<ThemeMode>`

### 8.3 Currency Preference
- Set a default "home currency" used across the app
- Used as the default "From" currency in the converter
- Used for displaying balances on the dashboard

### 8.4 Notifications
- Toggle for budget alerts (over 80% of budget)
- Toggle for weekly spending summary

### 8.5 Data Management
- Export expenses as CSV
- Clear all data (with confirmation dialog)

### 8.6 About Screen
- App version
- Licenses
- Links to privacy policy / terms

---

## 9. Design & UI Improvements

### 9.1 Floating Action Button (Add Expense)
Add a prominent `+` FAB on the Home and Expenses screens. This is the primary action in any expense tracker — it must be instantly accessible.

### 9.2 Empty States
Every list screen needs a meaningful empty state:
- Expenses list: illustration + "No expenses yet. Tap + to add one."
- Budget screen: "No budgets set. Tap to create your first budget."
- Conversion history: "No conversions yet."

### 9.3 Loading & Error States
Screens that fetch data (currency rates, future: cloud sync) need:
- Skeleton loading placeholders (not just a spinner)
- Error state with a retry button
- "No internet" banner

### 9.4 Onboarding → Feature Discovery
After first login, show a brief one-time tooltip tour highlighting:
- The + FAB for adding expenses
- The dashboard chart
- The budget section

### 9.5 Confirmation Dialogs
Destructive actions need confirmation:
- Delete expense → "Delete this expense?" with Cancel / Delete
- Clear all data → "This cannot be undone." with Cancel / Delete All

### 9.6 Navigation Tab Redesign
Current tab order: Home, Convert, Tax, Settings.

Suggested order once expenses exist:
```
Home (Dashboard) | Expenses | Tools (Convert + Tax) | Settings
```
Move Convert and Tax under a single "Tools" tab to make room for the Expenses tab which will be used daily.

---

## 10. Notifications (Advanced)

- Budget limit alerts (80% and 100% of budget reached)
- Daily reminder to log expenses (configurable time)
- Weekly spending summary every Monday

**Package:** `flutter_local_notifications`

---

## Feature Priority Order

| Priority | Feature | Effort |
|----------|---------|--------|
| 1 | Wire Login → AppShell (fix dead end) | Low |
| 2 | Add Expense form + local DB (Hive) | High |
| 3 | Expense list screen | Medium |
| 4 | Dashboard balance + recent transactions | Medium |
| 5 | Register screen | Low |
| 6 | Spending by category chart | Medium |
| 7 | Budget planner | Medium |
| 8 | Dark mode toggle (theme already exists) | Low |
| 9 | Real-time currency rates | Low |
| 10 | Complete tax brackets for all filing statuses | Low |
| 11 | Splash → auth gate logic | Low |
| 12 | Profile screen | Low |
| 13 | CSV export | Medium |
| 14 | Push notifications | High |
| 15 | Multi-country tax | High |
