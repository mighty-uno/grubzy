# Feature Context: Database Integration (SQLite & Turso)

## Overview
Integrates structured local storage (SQLite via `sqflite`) and optional cloud database sync (Turso over HTTP) to persist user stats, track active and historical orders, and manage the mock restaurant and dish catalog.

---

## 1. Architectural Decisions
*   **Local-First Operations**: A local SQLite database file `zepkit.db` acts as the primary data source. This guarantees instant, offline-capable interactions and ensures zero-latency cold starts.
*   **Optional Turso Sync**: When `tursoUrl` and `tursoToken` are configured, write transactions (such as updating stats or placing orders) are performed locally and replicated to Turso via the SQL over HTTP pipeline endpoint.
*   **Fault-Tolerant Fallbacks**: In case of network drops, service outages, or bad Turso credentials, the app silently falls back to local SQLite operations to avoid app crashes.

---

## 2. Database Schema Definition

### 1. `restaurants` Table
Stores details of available mock food venues.
```sql
CREATE TABLE restaurants (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  rating TEXT,
  delivery_time TEXT,
  calories_saved_string TEXT,
  discount_string TEXT,
  image_url TEXT,
  tags TEXT -- Comma-separated list of tags
);
```

### 2. `menu_items` Table
Stores the menu dishes related to each restaurant.
```sql
CREATE TABLE menu_items (
  id TEXT PRIMARY KEY,
  restaurant_id TEXT NOT NULL,
  name TEXT NOT NULL,
  price REAL NOT NULL,
  description TEXT,
  image_url TEXT,
  kcal INTEGER NOT NULL,
  type TEXT NOT NULL, -- 'veg', 'vegan', 'nonVeg'
  FOREIGN KEY (restaurant_id) REFERENCES restaurants (id) ON DELETE CASCADE
);
```

### 3. `orders` Table
Stores placed simulated orders for user order history and live delivery tracking.
```sql
CREATE TABLE orders (
  id TEXT PRIMARY KEY,
  restaurant_name TEXT NOT NULL,
  items_json TEXT NOT NULL, -- JSON string list of ordered items & customization details
  subtotal REAL NOT NULL,
  discount REAL NOT NULL,
  delivery_fee REAL NOT NULL,
  total REAL NOT NULL,
  status TEXT NOT NULL, -- 'placed', 'cooking', 'rider_pickup', 'delivering', 'delivered'
  calories_saved INTEGER NOT NULL,
  created_at TEXT NOT NULL, -- ISO 8601 datetime string
  rider_name TEXT -- Dynamically randomized delivery person name
);
```

### 4. `user_stats` Table
Stores the gamification levels, coins, and overall accumulated savings metrics.
```sql
CREATE TABLE user_stats (
  id TEXT PRIMARY KEY, -- Always 'current_user'
  crave_coins INTEGER NOT NULL,
  money_saved REAL NOT NULL,
  calories_saved INTEGER NOT NULL,
  orders_placed INTEGER NOT NULL,
  xp INTEGER NOT NULL,
  current_level INTEGER NOT NULL
);
```

---

## 3. Data Integration Patterns
*   **Startup Hydration**: On application initialize, `AppState` queries:
    1. The `user_stats` table to populate the user dashboard metrics.
    2. The `restaurants` and `menu_items` tables to load the active menus.
    3. The `orders` table to check if there are any active orders. If an order status is not `delivered`, the app automatically resumes the delivery tracking countdown where it left off!
*   **State Updates**: Callbacks to modify state (such as adding items, updating user stats, or placing orders) trigger simultaneous writes to local storage (SQLite) and replication to Turso.
