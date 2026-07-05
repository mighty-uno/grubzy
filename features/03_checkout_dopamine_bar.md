# Feature Context: Simulated Checkout & The Dopamine Bar

## Overview
Allows users to review their plate items, inspect the receipt, track saved cash, and place simulated orders with zero currency.

---

## 1. UX Intent & Behavioral Rationale
*   **The Dopamine Bar**: Displays the immediate positive reward of saving money. When users add items, the Dopamine Bar fills up dynamically, signaling progress.
*   **Visual Contrast (The Receipt)**: Subtotals display the full equivalent cost (e.g., "₹850"), but include a green discount line showing `100% OFF (-₹850)`, resulting in a grand total of `₹0`. This highlights the direct contrast between spending vs. saving.
*   **Reward Reinforcement**: Placing an order deducts nothing but rewards the user with `+30 CraveCoins` and `+40 XP` for successfully avoiding real spending.

---

## 2. Responsive UI Architecture
*   **Mobile (< 768px)**:
    *   Single vertical column stack (Plate Items List -> Savings Card -> Checkout Receipt -> CTA button fixed to viewport bottom).
*   **Web/Tablet (>= 768px)**:
    *   Two-column split view.
        *   **Left Column (3/5 width)**: Dynamic scrolling list of items with quantity adjusters.
        *   **Right Column (2/5 width)**: Sticky checkout summary containing the Dopamine Savings progress card and receipt details.

---

## 3. Flutter Implementation Specifications
*   **Interactive Row Layout**:
    ```dart
    // Web Responsive Split Row
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: ScrollableCartItemsList()),
        SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              DopamineSavingsCard(),
              SizedBox(height: 20),
              ReceiptSummaryCard(),
            ],
          ),
        ),
      ],
    )
    ```
*   **State Hooks (AppState)**:
    *   `state.cart`: plate items array listing `CartItem` elements.
    *   `state.cartSubtotal`: Sum of item prices, driving the Dopamine progress indicator level.
    *   `state.adjustQuantity(int index, int delta)`: Increments/decrements quantites, clearing elements when quantity reaches 0.
    *   `state.placeSimulatedOrder()`: Triggers checkout, adds values to total savings stats, clears the active cart, and launches the map tracker.
*   **Core UI Widgets**:
    *   `LinearProgressIndicator` styled with a bright success green gradient and shadow wraps to build the Dopamine Bar.
    *   `ElevatedButton` executing checkout actions.
