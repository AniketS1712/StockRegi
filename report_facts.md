# StockRegi Project Facts & Technical Report

---

## 1. STACK

### Flutter & Dart Version
```text
Flutter 3.41.6 • channel stable • https://github.com/flutter/flutter.git
Framework • revision db50e20168 (8 months ago) • 2026-03-25 16:21:00 -0700
Engine • hash 5cdd32777948fa7a648fac915f8da7120ac7e97a (revision 425cfb54d0) (7 months ago) • 2026-03-25 20:14:42.000Z
Tools • Dart 3.11.4 • DevTools 2.54.2
```

### Dependencies (`pubspec.yaml`)
- `flutter`: `sdk: flutter`
- `cupertino_icons`: `^1.0.8`
- `supabase_flutter`: `^2.17.2`
- `google_fonts`: `^8.2.1`
- `go_router`: `^17.5.0`
- `flutter_riverpod`: `^2.6.1`
- `flutter_native_splash`: `^2.4.4`
- `url_launcher`: `^6.3.2`

### Dev Dependencies (`pubspec.yaml`)
- `flutter_test`: `sdk: flutter`
- `flutter_lints`: `^6.0.0`
- `flutter_launcher_icons`: `^0.14.3`

### Android SDK & Application Config
- **Package ID / Application ID**: `com.silenteclipse.stockregi`
- **Application Version**: `1.0.0+1`
- **Minimum SDK (`minSdk`)**: Configured via `flutter.minSdkVersion` (Android API 21 / Android 5.0 Lollipop; also configured in `flutter_launcher_icons: min_sdk_android: 21`)
- **Target SDK (`targetSdk`)**: Configured via `flutter.targetSdkVersion` (Android API 35 / Android 15)
- **Compile SDK (`compileSdk`)**: Configured via `flutter.compileSdkVersion`

---

## 2. ARCHITECTURE

### Directory Structure (`lib/`, 2 Levels Deep)
```text
lib/
├── main.dart
├── models/
│   ├── attribute_key.dart
│   ├── attribute_row_model.dart
│   ├── business.dart
│   ├── category.dart
│   ├── item_attribute.dart
│   ├── item.dart
│   ├── production_form_state.dart
│   ├── stock_form_state.dart
│   ├── stock_level.dart
│   ├── transaction_line.dart
│   └── transaction.dart
├── providers/
│   ├── auth_providers.dart
│   ├── data_providers.dart
│   └── repository_providers.dart
├── repositories/
│   ├── attribute_key_repository.dart
│   ├── category_repository.dart
│   ├── item_repository.dart
│   ├── stock_repository.dart
│   └── transaction_repository.dart
├── router/
│   └── app_router.dart
├── screens/
│   ├── add_stock_screen.dart
│   ├── choose_role_screen.dart
│   ├── create_order_screen.dart
│   ├── dashboard_screen.dart
│   ├── inventory_screen.dart
│   ├── login_screen.dart
│   ├── order_history_screen.dart
│   ├── plan_selection_screen.dart
│   ├── production_screen.dart
│   ├── purchase_screen.dart
│   ├── set_password_screen.dart
│   ├── settings_screen.dart
│   ├── signup_screen.dart
│   └── splash_screen.dart
├── theme/
│   ├── app_colors.dart
│   ├── app_constants.dart
│   ├── app_spacing.dart
│   ├── app_theme.dart
│   └── app_typography.dart
├── utils/
│   └── format_utils.dart
└── widgets/
    ├── activity_tile.dart
    ├── app_branding.dart
    ├── app_loading_indicator.dart
    ├── app_logo.dart
    ├── attribute_row_widget.dart
    ├── auth_fields.dart
    ├── dashboard_widgets.dart
    ├── empty_state_card.dart
    ├── form_autocomplete_fields.dart
    ├── inline_banner.dart
    ├── inventory_item_card.dart
    ├── inventory_widgets.dart
    ├── metric_card.dart
    ├── new_badge.dart
    ├── order_history_card.dart
    ├── order_line_card.dart
    ├── order_widgets.dart
    ├── password_form_field.dart
    ├── primary_action_button.dart
    ├── production_cards.dart
    ├── scaffold_with_nav_bar.dart
    ├── section_label.dart
    ├── selectable_role_card.dart
    ├── selected_items_header.dart
    ├── settings_cards.dart
    ├── stock_item_form_fields.dart
    ├── stock_picker_chip.dart
    └── stockregi_app_bar.dart
```

### Folder Purposes
- `lib/models`: Immutable data transfer models representing database entities and mutable UI form states with JSON serialization.
- `lib/providers`: Riverpod state providers for reactive auth streams, async data queries, and repository dependency injection.
- `lib/repositories`: Data access layer interfacing directly with Supabase Postgres tables and stored procedures (RPCs).
- `lib/router`: GoRouter navigation hierarchy, bottom-navigation shell branches, and auth state redirect guards.
- `lib/screens`: View-layer screen widgets representing distinct top-level application destinations and forms.
- `lib/theme`: Visual design tokens including color palettes, typography scales, spacing constants, and ThemeData definitions.
- `lib/utils`: Formatting helpers for dates, currency values, decimal quantities, and string normalization.
- `lib/widgets`: Reusable modular UI components, form inputs, dashboard metric tiles, and navigation wrappers.

### State Management & Routing Approach
- **State Management**: Declarative, compile-time safe state management using **Flutter Riverpod** (`flutter_riverpod`). It leverages `StreamProvider` for realtime Supabase authentication state listening, `FutureProvider` and `FutureProvider.family` for reactive cached database queries with manual invalidation (`ref.invalidate`), and `Provider` for dependency injection of repository singletons and the router instance.
- **Routing Approach**: Declarative routing via **GoRouter** (`go_router`). Navigation utilizes a centralized, multi-stage redirect guard attached to a custom `ChangeNotifier` (`GoRouterRefreshStream`) that reacts to Supabase auth events and business profile changes. The main app experience uses a `StatefulShellRoute.indexedStack` with 4 persistent bottom tabs (`/dashboard`, `/inventory`, `/orders`, `/settings`), while full-screen modal flows (`/add-stock`, `/create-order`, `/purchase`, `/production`) are pushed on top of the shell stack.

---

## 3. SCREENS

| Screen File | Route Path | Purpose | Visible To |
| :--- | :--- | :--- | :--- |
| `splash_screen.dart` | `/splash` | Initial launch screen holding until minimum splash timer and session/business checks resolve | All (Cold start) |
| `login_screen.dart` | `/login` | Business username login form (resolves username to email via RPC) with password authentication | All (Unauthenticated) |
| `signup_screen.dart` | `/signup` | Single-form account registration with email and password | All (Unauthenticated) |
| `set_password_screen.dart` | `/reset-password` | Password recovery form allowing user to submit and confirm a new account password | All (Password recovery) |
| `choose_role_screen.dart` | `/choose-role` | Post-signup business onboarding to enter business name and select Seller or Producer role | All (New user with no business) |
| `plan_selection_screen.dart` | *(Unrouted)* | Subscription tier comparison screen (Free vs Pro tiers) | All (UI-only, unrouted) |
| `dashboard_screen.dart` | `/dashboard` | Main metrics hub showing Total Items, Low Stock count, quick action buttons, and recent activity | All (Actions adapt by role) |
| `inventory_screen.dart` | `/inventory` | Searchable stock levels list with filtering by category and raw materials vs finished goods | All |
| `order_history_screen.dart` | `/orders` | Chronological list of past customer sales orders with totals and line item breakdown | All |
| `settings_screen.dart` | `/settings` | Business details, role badge, theme settings, privacy policy link, sign out, and account deletion | All |
| `add_stock_screen.dart` | `/add-stock` | Dynamic multi-attribute inventory entry and purchase record form | Seller |
| `create_order_screen.dart` | `/create-order` | POS sales order creation form with item picker and atomic stock deduction | All (Seller & Producer) |
| `purchase_screen.dart` | `/purchase` | Raw material / inventory procurement recording form with pricing | Producer |
| `production_screen.dart` | `/production` | Multi-item manufacturing batch form consuming raw materials and producing finished goods | Producer |

---

## 4. MODELS & REPOSITORIES

### Models & Field Definitions

- **`AttributeKey`** (`lib/models/attribute_key.dart`):
  - `id`: `String`
  - `categoryId`: `String`
  - `keyName`: `String`
  - `createdAt`: `DateTime?`

- **`AttributeRowModel`** (`lib/models/attribute_row_model.dart`):
  - `keyId`: `String?`
  - `keyController`: `TextEditingController`
  - `valueController`: `TextEditingController`
  - `isPredefined`: `bool`
  - `valueSuggestions`: `List<String>`

- **`InitialFormData`** (`lib/models/attribute_row_model.dart`):
  - `categories`: `List<Category>`
  - `items`: `List<Item>`
  - `knownKeyNames`: `Set<String>`

- **`Business`** (`lib/models/business.dart`):
  - `id`: `String`
  - `ownerId`: `String`
  - `name`: `String`
  - `role`: `String` (`'seller'` or `'producer'`)
  - `createdAt`: `DateTime?`

- **`Category`** (`lib/models/category.dart`):
  - `id`: `String`
  - `businessId`: `String`
  - `name`: `String`
  - `createdAt`: `DateTime?`

- **`Item`** (`lib/models/item.dart`):
  - `id`: `String`
  - `businessId`: `String`
  - `categoryId`: `String`
  - `name`: `String`
  - `unit`: `String`
  - `isRawMaterial`: `bool`
  - `isFinishedGood`: `bool`
  - `createdAt`: `DateTime?`
  - `category`: `Category?`
  - `attributes`: `List<ItemAttribute>?`

- **`ItemAttribute`** (`lib/models/item_attribute.dart`):
  - `id`: `String`
  - `itemId`: `String`
  - `attributeKeyId`: `String`
  - `value`: `String`
  - `createdAt`: `DateTime?`
  - `attributeKeyName`: `String?`

- **`ProductionFormState`** (`lib/models/production_form_state.dart`):
  - `rawMaterialItems`: `List<Item>`
  - `stockMap`: `Map<String, double>`
  - `consumedRows`: `List<ConsumedItemRowModel>`
  - `categoryController`: `TextEditingController`
  - `itemNameController`: `TextEditingController`
  - `unitController`: `TextEditingController`
  - `quantityController`: `TextEditingController`
  - `categories`: `List<Category>`
  - `existingItems`: `List<Item>`
  - `matchedCategory`: `Category?`
  - `attributeRows`: `List<AttributeRowModel>`
  - `knownKeyNames`: `Set<String>`

- **`StockFormState`** (`lib/models/stock_form_state.dart`):
  - `categoryController`: `TextEditingController`
  - `itemNameController`: `TextEditingController`
  - `unitController`: `TextEditingController`
  - `quantityController`: `TextEditingController`
  - `unitPriceController`: `TextEditingController`
  - `attributeRows`: `List<AttributeRowModel>`
  - `knownKeyNames`: `Set<String>`
  - `categories`: `List<Category>`
  - `existingItems`: `List<Item>`
  - `matchedCategory`: `Category?`

- **`StockLevel`** (`lib/models/stock_level.dart`):
  - `itemId`: `String`
  - `businessId`: `String`
  - `quantity`: `double`
  - `updatedAt`: `DateTime?`
  - `item`: `Item?`

- **`Transaction`** (`lib/models/transaction.dart`):
  - `id`: `String`
  - `businessId`: `String`
  - `type`: `String` (`'purchase'`, `'production'`, `'order'`, or `'adjustment'`)
  - `notes`: `String?`
  - `createdAt`: `DateTime?`
  - `lines`: `List<TransactionLine>?`

- **`TransactionLine`** (`lib/models/transaction_line.dart`):
  - `id`: `String`
  - `transactionId`: `String`
  - `itemId`: `String`
  - `direction`: `String` (`'in'` or `'out'`)
  - `quantity`: `double`
  - `unitPrice`: `double?`
  - `createdAt`: `DateTime?`
  - `item`: `Item?`

- **Auxiliary Models**:
  - `OrderItemInput` (`lib/repositories/transaction_repository.dart`): `itemId`: `String`, `quantity`: `double`, `unitPrice`: `double?`
  - `ProductionItemInput` (`lib/repositories/transaction_repository.dart`): `itemId`: `String`, `quantity`: `double`
  - `ConsumedItemRowModel` (`lib/widgets/production_cards.dart`): `selectedItemId`: `String?`, `quantityController`: `TextEditingController`

---

### Repositories & Public Methods

- **`CategoryRepository`** (`lib/repositories/category_repository.dart`):
  - `getCategories(String businessId)`: Fetches all categories for a business ordered alphabetically.
  - `getOrCreateCategory(String businessId, String name)`: Fetches an existing category by case-insensitive name or inserts a new one.

- **`AttributeKeyRepository`** (`lib/repositories/attribute_key_repository.dart`):
  - `getAttributeKeys(String categoryId)`: Fetches all attribute keys defined for a category ordered alphabetically.
  - `getOrCreateAttributeKey(String categoryId, String keyName)`: Retrieves an existing attribute key by case-insensitive name or creates a new record.

- **`ItemRepository`** (`lib/repositories/item_repository.dart`):
  - `getItems(String businessId)`: Fetches all items with nested categories and item attributes for a business.
  - `getRawMaterialItems(String businessId)`: Fetches only items designated as raw materials (`is_raw_material = true`).
  - `getOrCreateItem(...)`: Looks up an item matching business, category, normalized name, unit, and exact attribute set, or creates a new item with attributes.

- **`StockRepository`** (`lib/repositories/stock_repository.dart`):
  - `getStockLevels(String businessId)`: Fetches all current stock levels with nested item, category, and attribute details.
  - `getDistinctAttributeValues(String attributeKeyId)`: Retrieves all distinct past values used for an attribute key for autocomplete suggestions.

- **`TransactionRepository`** (`lib/repositories/transaction_repository.dart`):
  - `createPurchase(...)`: Creates a purchase transaction and incoming stock line item.
  - `createOrder(...)`: Atomically executes a sales order and decrements stock via the `create_order` PostgreSQL RPC.
  - `createProduction(...)`: Atomically executes a manufacturing run consuming raw materials and producing finished goods via the `create_production` PostgreSQL RPC.
  - `createAdjustment(...)`: Records an inventory adjustment (positive or negative) with a transaction and line.
  - `getRecentActivity(String businessId, {int limit = 5})`: Fetches the most recent transactions with lines and items for the dashboard.
  - `getOrderHistory(String businessId)`: Fetches all completed order transactions with item details for the order history view.

---

## 5. PROVIDERS

| Provider Name | Provider Type | What It Exposes | File |
| :--- | :--- | :--- | :--- |
| `authStateProvider` | `StreamProvider<AuthState>` | Broadcast stream of Supabase authentication state changes | `lib/providers/auth_providers.dart` |
| `currentBusinessProvider` | `FutureProvider<Business?>` | The active business record owned by the currently authenticated user | `lib/providers/auth_providers.dart` |
| `splashMinDelayProvider` | `FutureProvider<void>` | Enforces a 2-second minimum presentation delay for the splash screen on cold start | `lib/providers/auth_providers.dart` |
| `stockLevelsProvider` | `FutureProvider.family<List<StockLevel>, String>` | List of current stock levels with joined item relations for a given business ID | `lib/providers/data_providers.dart` |
| `categoriesProvider` | `FutureProvider.family<List<Category>, String>` | List of all item categories for a given business ID | `lib/providers/data_providers.dart` |
| `itemsProvider` | `FutureProvider.family<List<Item>, String>` | List of all items with categories and attributes for a given business ID | `lib/providers/data_providers.dart` |
| `recentActivityProvider` | `FutureProvider.family<List<Transaction>, String>` | The 5 most recent transactions with lines and items for a given business ID | `lib/providers/data_providers.dart` |
| `orderHistoryProvider` | `FutureProvider.family<List<Transaction>, String>` | All order-type transactions with line items for a given business ID | `lib/providers/data_providers.dart` |
| `categoryRepositoryProvider` | `Provider<CategoryRepository>` | Singleton instance of `CategoryRepository` initialized with Supabase client | `lib/providers/repository_providers.dart` |
| `attributeKeyRepositoryProvider` | `Provider<AttributeKeyRepository>` | Singleton instance of `AttributeKeyRepository` initialized with Supabase client | `lib/providers/repository_providers.dart` |
| `itemRepositoryProvider` | `Provider<ItemRepository>` | Singleton instance of `ItemRepository` initialized with Supabase client | `lib/providers/repository_providers.dart` |
| `stockRepositoryProvider` | `Provider<StockRepository>` | Singleton instance of `StockRepository` initialized with Supabase client | `lib/providers/repository_providers.dart` |
| `transactionRepositoryProvider` | `Provider<TransactionRepository>` | Singleton instance of `TransactionRepository` initialized with Supabase client | `lib/providers/repository_providers.dart` |
| `routerProvider` | `Provider<GoRouter>` | Configured root GoRouter instance with redirect guards and routes table | `lib/router/app_router.dart` |

---

## 6. AUTH & ROUTING

### Router Redirect States (in Exact Code Order)
1. **Cold Start Delay**: If `splashDelayAsync.isLoading` is true, force route to `/splash` until the 2-second minimum splash timer finishes.
2. **Splash Data Resolution**: While on `/splash`, if either `authStateAsync.isLoading` or `businessAsync.isLoading` is true, remain on `/splash` (`return null`).
3. **State 1 (Unauthenticated)**: If `hasSession` is false (`currentSession == null`), allow `/login`, `/signup`, and `/reset-password`; for all other routes, redirect to `/login`.
4. **State 2 (Authenticated, No Business Profile)**: If `hasSession` is true but `business == null`, allow `/reset-password`; for any other route that is not `/choose-role`, redirect to `/choose-role`.
5. **State 3 (Authenticated, Business Exists)**: If `hasSession` is true and `business != null`, visiting onboarding/auth routes (`/choose-role`, `/login`, `/signup`, `/splash`, `/plan-selection`) automatically redirects to `/dashboard`.
6. **Default Route Access**: For any other authenticated route (`/inventory`, `/orders`, `/settings`, modals), allow navigation (`return null`).

---

### Step-by-Step Current Flows

#### 1. Sign Up Flow
1. User opens the app and navigates to `/signup` (`SignUpScreen`).
2. User enters an email and password (minimum 6 characters).
3. On form submit, `Supabase.instance.client.auth.signUp(email: ..., password: ...)` is called.
4. Supabase creates the user account and returns an authenticated session immediately (email confirmation disabled).
5. Supabase emits an auth state change event, triggering `GoRouterRefreshStream`.
6. Router redirect evaluates: session exists, but `currentBusinessProvider` is null (no business profile exists yet).
7. Router automatically redirects user to `/choose-role` (`ChooseRoleScreen`).
8. User enters business name, selects business role (`seller` or `producer`), and taps submit.
9. Business row is inserted into the `businesses` table, and `currentBusinessProvider` is invalidated.
10. Router redirect evaluates: session exists and business row is now present.
11. Router automatically redirects user to `/dashboard` (`DashboardScreen`).

#### 2. Log In Flow
1. User opens the app and lands on `/login` (`LoginScreen`).
2. User enters Username (Business Name) and Password.
3. On submit, app calls PostgreSQL RPC `get_email_for_username(input_username: username)` to lookup the registered email for that business name.
4. If found, the app calls `Supabase.instance.client.auth.signInWithPassword(email: resolvedEmail, password: password)`.
5. Supabase verifies credentials and returns an active session.
6. `currentBusinessProvider` resolves the user's business profile.
7. Router redirect evaluates: session exists and business row exists.
8. Router automatically redirects user to `/dashboard` (`DashboardScreen`).

#### 3. Forgot Password Flow
1. User receives a password recovery deep-link or navigates to `/reset-password` (`SetPasswordScreen` with `mode: SetPasswordMode.reset`).
2. Form presents "New Password" and "Confirm Password" fields with minimum 6 character validation and matching checks.
3. User enters new password and submits form.
4. App calls `Supabase.instance.client.auth.updateUser(UserAttributes(password: password))`.
5. Supabase updates the password in `auth.users`.
*(Note: Initiation of password recovery email from the login UI is currently missing in `LoginScreen`).*

#### 4. Delete Account Flow
1. User navigates to Settings tab (`/settings`, `SettingsScreen`) and taps "Delete Account".
2. App shows an irreversible warning confirmation dialog.
3. When confirmed, a non-dismissible loading dialog appears.
4. App deletes the user's business row: `client.from('businesses').delete().eq('owner_id', user.id)` (cascading across all inventory, transactions, and lines).
5. App calls Supabase Edge Function `client.functions.invoke('delete-account')`, which uses the server-side service role key to permanently delete the user from `auth.users`.
6. App calls `client.auth.signOut()`.
7. GoRouter detects the auth change and redirects to `/login`.

---

## 7. FEATURE STATUS

| Feature | Status | Proving File & Technical Evidence |
| :--- | :--- | :--- |
| **Seller Flow** | **Working** | `lib/screens/add_stock_screen.dart`, `lib/screens/create_order_screen.dart`, `lib/repositories/transaction_repository.dart`<br>• Seller can add stock with categories/attributes (inflow) and execute POS orders via `create_order` RPC with atomic stock deductions. |
| **Producer Flow** | **Working** | `lib/screens/purchase_screen.dart`, `lib/screens/production_screen.dart`, `lib/repositories/transaction_repository.dart`<br>• Producer can purchase raw materials, run multi-item manufacturing batches via `create_production` RPC consuming raw materials and producing finished goods, and fulfill sales orders. |
| **Plan Selection** | **UI-only** | `lib/screens/plan_selection_screen.dart`<br>• Screen exists with UI pricing toggles ($15/$29/mo), but button simply calls `context.go('/dashboard')` with no billing/Stripe integration, and route is not registered in `app_router.dart`. |
| **Forgot Password** | **Missing / Partial** | `lib/screens/login_screen.dart`, `lib/screens/set_password_screen.dart`<br>• Initiation is **Missing** (no "Forgot Password" link or `resetPasswordForEmail` call in `login_screen.dart`). Target reset form is **Working** at `/reset-password` in `set_password_screen.dart`. |
| **Delete Account** | **Working** | `lib/screens/settings_screen.dart`<br>• Fully implemented: deletes business data, invokes active Supabase Edge Function `delete-account` to remove the auth user, and signs out. |
| **Privacy Policy Link** | **Working** | `lib/screens/settings_screen.dart`<br>• Fully implemented: uses `url_launcher` (`launchUrl`) with `LaunchMode.externalApplication` to open `https://saniket.vercel.app/stockregi-privacy`. |
| **Release Signing** | **Working / Configured** | `android/app/build.gradle.kts`<br>• Fully configured: `signingConfigs.release` loads credentials from `key.properties` (with debug fallback if properties are missing). |

---

## 8. CODE EXCERPTS

### 1. `getOrCreateItem` (Search & Deduplication Logic)
*Source: `lib/repositories/item_repository.dart` (lines 48–85)*
```dart
  }) async {
    final normName = name.trim().toLowerCase();
    final normUnit = unit.trim().toLowerCase();

    // Build a normalized version of the incoming attributes for comparison.
    // Key = attributeKeyId, Value = trimmed+lowercased value.
    final Map<String, String> normIncoming = {
      for (final e in attributes.entries)
        if (e.value.trim().isNotEmpty) e.key: e.value.trim().toLowerCase(),
    };

    // Fetch candidate items that share the same business, category,
    // and case-insensitive name + unit.
    final candidates = await _supabase
        .from('items')
        .select('*, categories(*), item_attributes(*, attribute_keys(*))')
        .eq('business_id', businessId)
        .eq('category_id', categoryId)
        .ilike('name', normName)
        .ilike('unit', normUnit);

    for (final row in (candidates as List)) {
      final candidateJson = row as Map<String, dynamic>;
      final candidate = Item.fromJson(candidateJson);

      // Build a normalized map from the candidate's existing attributes.
      final candAttrs = <String, String>{};
      if (candidate.attributes != null) {
        for (final a in candidate.attributes!) {
          candAttrs[a.attributeKeyId] = a.value.trim().toLowerCase();
        }
      }

      // Same number of attribute keys?
      if (candAttrs.length != normIncoming.length) continue;

      // All keys present and values match?
      bool allMatch = true;
      for (final key in normIncoming.keys) {
        if (candAttrs[key] != normIncoming[key]) {
```

### 2. Router Redirect Function
*Source: `lib/router/app_router.dart` (lines 67–106)*
```dart
      // Initial splash screen delay on cold start
      if (splashDelayAsync.isLoading) {
        if (loc != '/splash') return '/splash';
        return null;
      }

      // If on splash, wait until auth & business state resolve before navigating away
      if (loc == '/splash' &&
          (authStateAsync.isLoading || businessAsync.isLoading)) {
        return null;
      }

      final hasSession = Supabase.instance.client.auth.currentSession != null;

      // State 1: No authenticated Supabase session -> show Login/Signup
      if (!hasSession) {
        if (loc != '/login' && loc != '/signup' && loc != '/reset-password') return '/login';
        return null;
      }

      final business = businessAsync.valueOrNull;

      // State 2: Session exists, but no business row exists yet -> /choose-role
      if (business == null) {
        if (loc == '/reset-password') return null;
        if (loc != '/choose-role') return '/choose-role';
        return null;
      }

      // State 3: Session exists AND a business row exists -> Dashboard
      if (loc == '/choose-role' ||
          loc == '/login' ||
          loc == '/signup' ||
          loc == '/splash' ||
          loc == '/plan-selection') {
        return '/dashboard';
      }

      // Allow access to requested route
      return null;
```

### 3. `createOrder` in `TransactionRepository`
*Source: `lib/repositories/transaction_repository.dart` (lines 71–100)*
```dart
  Future<Transaction> createOrder({
    required String businessId,
    required List<OrderItemInput> items,
    String? notes,
  }) async {
    final linesJson = items
        .map((item) => {
              'item_id': item.itemId,
              'quantity': item.quantity,
              if (item.unitPrice != null) 'unit_price': item.unitPrice,
            })
        .toList();

    final txId = await _supabase.rpc<String>(
      'create_order',
      params: {
        'p_business_id': businessId,
        'p_lines': linesJson,
        'p_notes': notes,
      },
    );

    final fullTx = await _supabase
        .from('transactions')
        .select('*, transaction_lines(*, items(*))')
        .eq('id', txId)
        .single();

    return Transaction.fromJson(fullTx);
  }
```

### 4. `createProduction` in `TransactionRepository`
*Source: `lib/repositories/transaction_repository.dart` (lines 105–133)*
```dart
  Future<Transaction> createProduction({
    required String businessId,
    required List<ProductionItemInput> consumed,
    required List<ProductionItemInput> produced,
    String? notes,
  }) async {
    final consumedJson =
        consumed.map((i) => {'item_id': i.itemId, 'quantity': i.quantity}).toList();
    final producedJson =
        produced.map((i) => {'item_id': i.itemId, 'quantity': i.quantity}).toList();

    final txId = await _supabase.rpc<String>(
      'create_production',
      params: {
        'p_business_id': businessId,
        'p_consumed': consumedJson,
        'p_produced': producedJson,
        'p_notes': notes,
      },
    );

    final fullTx = await _supabase
        .from('transactions')
        .select('*, transaction_lines(*, items(*))')
        .eq('id', txId)
        .single();

    return Transaction.fromJson(fullTx);
  }
```

---

## 9. STATS

- **Total `.dart` Files in Project**: 69
- **Total Lines of Dart Code in `lib/`**: 7,225
- **Screens Count**: 14 files (`lib/screens/`)
- **Widgets Count**: 28 files (`lib/widgets/`)
- **Repositories Count**: 5 files (`lib/repositories/`)
- **Providers Count**: 3 provider files in `lib/providers/` (defining 14 distinct providers throughout the app, including 5 family providers and `routerProvider`)

---

## 10. TESTS

### Directory: `bin/`
- **Status**: Directory does not exist in the project repository.

### Directory: `test_results/`
- **`test_results/producer_flow_results.md`**: 10 integration test cases (10 passed)
  - Tests 1–3: Raw material & finished goods procurement, deduplication, and cumulative stock calculation.
  - Tests 4–5: Production conversion, yield verification, and non-negative stock constraint enforcement.
  - Tests 6–7: Order creation, stock deduction, and negative stock constraint rejection.
  - Tests 8–10: Business cross-tenant authorization, item ownership security, and tenant data isolation.
- **`test_results/seller_flow_results.md`**: 9 integration test cases (9 passed)
  - Tests 1–3: Add stock for new/existing items, dynamic category/attribute creation, and cumulative stock.
  - Tests 4–5: Sales order stock deduction and over-stock order rejection.
  - Tests 6–8: Cross-business authorization guards, foreign item order rejection, and multi-tenant isolation.
  - Test 9: Role boundary verification on direct RPC execution.

