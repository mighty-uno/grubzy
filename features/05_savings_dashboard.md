# Feature Context: Habit & Savings Dashboard

## Overview
Analytics panels visualising real money saved, calories dodged, level progress rankings, and unlocked real-world milestones.

---

## 1. UX Intent & Behavioral Rationale
*   **The Savings Jars**: Helps users visualize their cumulative progress. Instead of just showing numbers, it translates saved money into real rewards they can now afford (e.g. Starbucks coffee, movie tickets, gym membership).
*   **Gamified Ranks**: Introduces competitive levels (Samosa Spectator -> Momo Mediator -> Chaat Challenger -> Dosa Dominator -> Biryani Buddha) using XP points to keep users engaged.
*   **Habit Tracker Utility**: Transforms a simulator into a meaningful tool for breaking delivery habits.

---

## 2. Responsive UI Architecture
*   **Mobile (< 768px)**:
    *   Single-column grid. The stats cards stack vertically.
    *   Savings goal list stacks below the XP progress card.
*   **Web/Tablet (>= 768px)**:
    *   Multi-grid layout:
        *   **Top Row**: 3 wide columns showing numeric statistics.
        *   **Bottom Row (Split)**: Left card displays the XP Level Progress bar; Right card renders the milestones lists.

---

## 3. Flutter Implementation Specifications
*   **Grid layout structures**:
    ```dart
    // Responsive Stats Cards
    GridView(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 3,
        childAspectRatio: isMobile ? 3 : 2.5,
      ),
      children: [
        MoneySavedCard(),
        CaloriesDodgedCard(),
        OrdersPlacedCard(),
      ],
    )
    ```
*   **State Hooks (AppState)**:
    *   `state.moneySaved`: Accumulates subtotal savings from checkouts.
    *   `state.caloriesSaved`: Sum of avoided calories.
    *   `state.ordersPlaced`: Total successful simulated deliveries.
    *   `state.currentLevel` & `state.xp`: Gamified level parameters.
    *   `state.levelTitle`: Toggles rank string descriptors.
    *   `state.milestones`: Data array detailing unlockable milestone costs.
*   **Core UI Widgets**:
    *   `LinearProgressIndicator` for experience progress.
    *   `Card` styled using custom elevations and Pistachio Green borders for unlocked statuses.
    *   `CircleAvatar` holding icon badges for statistics cards.
