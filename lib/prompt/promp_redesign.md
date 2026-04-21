You are a senior Flutter architect and engineer with 15+ years of experience building scalable, production-grade fintech and productivity apps.

Your task is to design and implement a complete mobile application called **Xpenser**, an advanced expense tracking and budgeting app.

## Tech Stack Requirements

* Flutter (latest stable)
* State Management: Riverpod (prefer Notifier/StateNotifier)
* Navigation: GoRouter
* Local Database: Hive (initially)
* Architecture: Clean Architecture (presentation, domain, data layers)
* Code Style: SOLID principles, modular, scalable, testable

---

## Core Requirements

### 1. App Flow

Implement a seamless flow:
Splash → Onboarding → Auth → AppShell

Handle:

* First launch detection
* Persistent login session
* Redirect logic using GoRouter

---

### 2. Authentication

* Email/password login & registration
* Form validation (email, password strength)
* Loading + error states
* Forgot password flow

---

### 3. Multi-Account System

Users can create and manage accounts:

* Cash, Bank, Mobile Money, Savings
* Transactions must be linked to accounts
* Support transfers between accounts

---

### 4. Expense & Income Management

* Add/Edit/Delete transactions
* Fields: amount, category, account, date, notes
* Support income and expenses
* Swipe-to-delete with undo
* Grouped list (Today, Yesterday, etc.)

---

### 5. Recurring Transactions

* Allow marking transactions as recurring
* Frequency: daily, weekly, monthly
* Auto-generate entries

---

### 6. Dashboard (Highly polished UI)

Include:

* Balance summary (animated)
* Recent transactions
* Spending chart (animated)
* Budget progress bars

---

### 7. Budget System

* Set monthly limits per category
* Show progress bars
* Trigger alerts at thresholds

---

### 8. Smart Features

* Spending insights (basic analytics)
* Trend comparison (monthly/weekly)
* Auto-category suggestion (simple logic)

---

### 9. Additional Features

* Currency converter (API-based, cached)
* Tax calculator (multi-country support)
* Savings goals tracking
* Tags system for transactions
* Global search

---

### 10. Settings

* Profile management
* Dark mode toggle
* Currency preference
* Notifications
* Data export/import

---

## UI/UX Requirements

* Clean, modern fintech UI
* Smooth animations (micro-interactions)
* Proper empty states, loading states, and error states
* Use subtle motion for transitions (no over-animation)
* FAB for primary actions

---

## Performance & UX

* Offline-first design
* Fast list rendering
* Efficient state updates
* Avoid unnecessary rebuilds

---

## Deliverables

* Folder structure
* Core models
* ViewModels
* Routing setup (GoRouter)
* Example screens (Dashboard, Add Expense, Expense List)
* Reusable widgets

Focus on writing clean, maintainable code and avoid overengineering.

Prioritize user experience, responsiveness, and scalability.
