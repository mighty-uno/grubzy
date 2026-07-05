# Feature Context: Simulated Restaurant Browsing

## Overview
Allows users to scroll through a catalog of realistic Indian restaurants (Biryani, Chaat, Mughlai) with high-fidelity food imagery, ratings, mock times, and funny promotions.

---

## 1. UX Intent & Behavioral Rationale
*   **The Craving Loop**: Food ordering addiction often starts with the visual scroll. By mimicking the dense restaurant feed layout of Swiggy and Zomato, the app triggers and redirects the user's initial craving.
*   **The Illusion of Cost**: Every listing displays standard prices, but has tags like *"100% OFF (MAX ₹0)"* or *"Unlimited Virtual Sukha Puri"* to inject humor and relieve the pressure of spending.

---

## 2. Responsive UI Architecture
*   **Mobile (< 768px)**:
    *   Single-column vertical scrolling list.
    *   Top sticky category carousel containing horizontal circular chips with category icons.
    *   Search bar fixed below the app header.
*   **Web/Tablet (>= 768px)**:
    *   Multi-column card grid. The column count is calculated dynamically based on width: `MediaQuery.of(context).size.width ~/ 300`.
    *   Left-hand navigation rail acts as the primary layout menu.

---

## 3. Flutter Implementation Specifications
*   **Layout Widget Pattern**:
    ```dart
    // Mobile Layout: ListView/CustomScrollView
    CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: CategoriesSlider()),
        SliverList(delegate: SliverChildBuilderDelegate(...)),
      ],
    )
    
    // Web Layout: Responsive GridView
    GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: screenWidth > 900 ? 3 : 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      ...
    )
    ```
*   **AppState (AppState)**:
    *   `state.restaurants`: List of `Restaurant` models loaded from data memory.
    *   `state.searchQuery`: String query driving dynamic filtration of restaurant list.
    *   `state.activeCategory`: Toggles which tags to filter by.
*   **Core UI Widgets**:
    *   `FilterChip` representing categories.
    *   `Card` containing an `InkWell` for click ripple feedback, using background network images (`Image.network`) and customized overlay badges.

---

## 4. Menu & Food Type Filtering Specifications
*   **Navigation Flow**: Tapping a restaurant card now opens a full-screen or half-screen **Restaurant Menu Bottom Sheet** detailing all items served by that venue.
*   **Food Preferences Filter**: 
    *   Items are categorised using a `FoodType` enum: `veg` (Vegetarian), `vegan` (Vegan), and `nonVeg` (Non-Vegetarian).
    *   Within the Menu sheet, users can toggle filter chips: **All**, **Veg 🟢**, **Vegan ☘️**, or **Non-Veg 🔴**.
*   **Interactive Cart Customizer**: Tapping "Add" on any filtered menu item routes the user to the customizer view to select spice levels/addons, before placing it into their active cart list.
