# Feature Context: Payment Flow Confirmation Step

## Overview
Inserts a payment option selection step in the checkout flow, preventing accidental placement of simulated orders and providing a premium Cash on Delivery payment UI.

---

## 1. UX Flow & Layout Specs
*   **Checkout Redirection**: When clicking `"Proceed to Payment"` in the Cart viewport, the app opens the `PaymentDialog` overlay.
*   **Billing Receipt Summary**: Displays items total, full virtual discounts, free delivery fees, and order dues (totaling ₹0).
*   **Payment Options**:
    *   Lists a single, check-marked payment card for **Cash on Delivery**.
    *   Prominently displays the trust tagline: *"We trust you with money"*.
    *   Uses green border highlight and trust shield/wallet icons to look extremely premium.
*   **Actions**:
    *   Tapping `"Confirm COD & Place Order"` dismisses the overlay and returns confirmation status.
    *   Dismissing or canceling returns `null`/`false`, stopping placement.

---

## 2. Flutter Layout Code Structure
```dart
showDialog<bool>(
  context: context,
  builder: (context) => const PaymentDialog(subtotal: subtotal),
).then((confirmed) {
  if (confirmed == true) {
    // Show success dialog, place order, and route
  }
});
```
*   Ensures clean separation of billing layout concerns and checkout callbacks.
