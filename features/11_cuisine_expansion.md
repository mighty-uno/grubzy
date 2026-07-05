# Feature Context: Cuisine Expansion & Seeding Migration

## Overview
Adds three new world-cuisine restaurants to seed datasets to expand menu selections and give users a more diverse set of virtual options.

---

## 1. Restaurant Catalog & Menu Specifications

### A. La Trattoria (Italian)
*   **Tags**: `Italian,Pasta,Pizza`
*   **Delivery Time**: 22 mins
*   **Image**: Unsplash photo featuring freshly made Italian dishes.
*   **Menu Items**:
    1.  *Ghost Truffle Fettuccine*: Fettuccine with butter and white truffles. (₹490, 780 kcal, Veg)
    2.  *Mirage Margherita Pizza*: Mozzarella, tomatoes, and basil pizza. (₹360, 640 kcal, Veg)
    3.  *Tiramisu Illusion*: Sponge fingers with espresso and mascarpone. (₹240, 450 kcal, Veg)

### B. Kyoto Sushi (Japanese)
*   **Tags**: `Japanese,Sushi,Healthy-ish`
*   **Delivery Time**: 16 mins
*   **Image**: Unsplash photo of sushi rolls and sashimi platter.
*   **Menu Items**:
    1.  *Dopamine Salmon Sushi Platter*: Fresh salmon nigiri and sashimi platter. (₹550, 420 kcal, Non-Veg)
    2.  *Simulated Spicy Ramen*: Spicy noodle soup with egg and scallions. (₹380, 680 kcal, Non-Veg)
    3.  *Ghost Avocado Maki (8 Pcs)*: Nori wrapped avocado roll. (₹220, 250 kcal, Vegan)

### C. Cantina Mexicana (Mexican)
*   **Tags**: `Mexican,Tacos,Street Food`
*   **Delivery Time**: 20 mins
*   **Image**: Unsplash photo featuring authentic Mexican street food.
*   **Menu Items**:
    1.  *Simulated Birria Tacos (3 Pcs)*: Beef and cheese corn tacos with consommé dipping soup. (₹340, 790 kcal, Non-Veg)
    2.  *Ghost Quesadilla Gigante*: Monterey jack cheese quesadilla with hot salsa. (₹290, 540 kcal, Veg)
    3.  *Dopamine Churros with Caramel*: Cinnamon sugar churros with warm caramel dip. (₹180, 420 kcal, Veg)

---

## 2. OnOpen Check Migration
To seed these items automatically on existing installations, the `onOpen` SQLite callback verifies if `id IN ('r6', 'r7', 'r8')` query returns 3 rows. If not, it executes conflict-ignored insert operations for these records.
