# Feature Context: Order History & Infinite Pagination

## Overview
Allows users to browse a historical log of their virtual checkouts by clicking the "Ghost Orders Placed" stat card on the dashboard. The list implements dynamic paginated loading driven by scroll threshold intersections.

---

## 1. Pagination Mechanics & UX Design
To optimize startup performance and minimize database query locks, orders are loaded in batches:
*   **Batch Size**: 5 orders per page.
*   **Trigger Event**: Scroll controller position offsets intersecting within 100 pixels of the scroll boundary limits.
*   **Simulation Delay**: An intentional 800ms timer delay is simulated during query transactions to present sleek, glassy progress spinners.
*   **Empty State Handler**: If no orders exist in SQLite, displays a themed message: *"Your virtual stomach is empty!"*.

---

## 2. SQL Fetch Syntax
The paginated queries utilize the standard SQL `LIMIT` and `OFFSET` clauses:
```sql
SELECT * FROM orders ORDER BY created_at DESC LIMIT ? OFFSET ?
```
*   `LIMIT`: Batches the output count (5).
*   `OFFSET`: Points to the current scroll cursor index (`page * 5`).

---

## 3. History Item Card Design
Each card represents a historical virtual delivery:
*   **Header**: Restaurant title and a status badge indicating the delivery phase (`placed`, `cooking`, `rider_pickup`, `delivering`, `delivered`).
*   **Itemized List**: Expands the parsed `items_json` column to list the names, custom spices, and quantity counts of the ordered dishes.
*   **Gamification Stats**: Showcases CraveCoins awarded and total dodged calories.
