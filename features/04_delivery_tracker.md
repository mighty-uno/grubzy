# Feature Context: Live Delivery Tracker Simulation

## Overview
A gamified tracking screen displaying a simulated route map and step timeline, mocking the delivery steps with humorous updates.

---

## 1. UX Intent & Behavioral Rationale
*   **The Anticipation Stage**: When ordering food, waiting for the delivery rider is a crucial part of the dopamine loop. By providing a simulated progress map and text updates, the app feeds this anticipation.
*   **Humor & Lightheartedness**: The status steps are designed to be funny, detailing things like:
    1.  *Chef is thinking deeply about your Paneer Tikka.*
    2.  *Rider Raju is speeding past virtual speed bumps.*
    3.  *Rider is inhaling the virtual aroma.*
    4.  *Delivered! Open your mouth and take a deep breath.*
*   **Aroma Delivery**: Upon completion, the app notifies the user to take a deep virtual breath to "consume" the meal, satisfying the craving without calories.

---

## 2. Responsive UI Architecture
*   **Mobile (< 768px)**:
    *   Stacked layout. The map container takes the top half, and the updates timeline fills the bottom.
*   **Web/Tablet (>= 768px)**:
    *   Split-screen grid layout:
        *   **Left Column (1.2x width)**: Large interactive map simulation block.
        *   **Right Column (1x width)**: Timeline detail card.

---

## 3. Flutter Implementation Specifications
*   **Map Layout Stack**:
    Uses a `Stack` layout with an `AnimatedAlign` widget representing the delivery rider. The horizontal alignment factor translates the progress coordinates smoothly.
    ```dart
    Stack(
      children: [
        // Road Line Grid
        Center(child: DottedPathLine()),
        // Store Node
        Positioned(left: 20, child: StoreNodeWidget()),
        // User Home Node
        Positioned(right: 20, child: HomeNodeWidget()),
        // Rider Icon
        AnimatedAlign(
          duration: Duration(seconds: 3),
          curve: Curves.easeInOut,
          alignment: Alignment(-1.0 + (state.riderPositionPercentage * 2.0), 0.0),
          child: RiderIconWidget(),
        ),
      ],
    )
    ```
*   **State Hooks (AppState)**:
    *   `state.isTrackingActive`: Boolean lock controlling timers.
    *   `state.riderPositionPercentage`: Double factor (0.1 -> 0.9) positioning the rider.
    *   `state.currentTrackingStep`: Step index (0 to 3) representing active timeline segments.
    *   `state.trackingStatusText`: Display badge status string.
    *   `state.riderName`: The dynamically randomized and persisted name of the delivery rider (e.g. Raju Rocket, Bunty Bullet).
*   **Core UI Widgets**:
    *   `AnimatedAlign` for the rider position.
    *   One-shot `Timer` scheduled recursively with a randomized duration (e.g. 3 to 7 seconds per segment) to simulate dynamic delivery pacing.
    *   Custom vertical timeline showing the current steps bound to `state.riderName`.
    *   Lightning-fast delivery banner card showing the fee waiver: *"We don't charge delivery fee"*.
