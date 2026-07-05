# Feature Context: Menu & Cart Customization

## Overview
Allows users to open specific dishes, customize parameters (e.g. spice level, virtual toppings), and add them to their active simulated cart (plate).

---

## 1. UX Intent & Behavioral Rationale
*   **Agency & Control**: Customizing a food item satisfies the psychological urge of ordering ("I want this exact dish, this spicy, with extra cheese"). It mimics the decision-making process of food ordering apps.
*   **The Dopamine Tap**: Every addition to the cart is accompanied by screen haptics, UI popups, and numerical badge updates to trigger a micro-reward response without actual spending.
*   **Price Anchor**: All add-ons and base selections display their real equivalent value, reminding the user how much money they would have spent.

---

## 2. Responsive UI Architecture
*   **Mobile (< 768px)**:
    *   Opens as a Draggable Modal Bottom Sheet (`showModalBottomSheet` with `DraggableScrollableSheet`) sliding up from the bottom of the screen.
    *   Occupies 75% to 90% of screen height.
*   **Web/Tablet (>= 768px)**:
    *   Opens as a centered floating Dialog card (`showDialog`) or right-side slide-over panel.
    *   Width constrained to a maximum of 500dp.

---

## 3. Flutter Implementation Specifications
*   **Interactive Modal Sheets**:
    ```dart
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: AppTheme.borderLarge),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return FoodCustomizerSheet(item: item, scrollController: scrollController);
          },
        );
      },
    );
    ```
*   **State Hooks (AppState & Sheet State)**:
    *   `_selectedSpice`: Radio selector (`ChoiceChip` in Flutter) containing options `['Mild', 'Indian Spicy', 'Spicy AF']`.
    *   `_selectedAddons`: Array list checking checkbox widgets.
    *   `state.addToCart(MenuItem item, String spice, List<String> addons)`: State event appending the customized card to the global plate.
*   **Core UI Widgets**:
    *   `ChoiceChip` for custom options.
    *   `CheckboxListTile` for multiple add-ons.
    *   `ElevatedButton` locked at the bottom to trigger submissions.
