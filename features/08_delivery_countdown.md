# Feature Context: Delivery Countdown Timer

## Overview
Synchronizes the simulated tracking process with a real-time countdown timer that ticks down every second. It calculates delivery progress ratios mathematically and displays estimated arrival time in a premium MM:SS clock card.

---

## 1. Mathematical Logic & Mapping
On order placement, a random delivery duration $D$ is selected (e.g. 40 to 70 seconds). Every second, remaining seconds $R$ decrement by 1.

The overall completion percentage is calculated as:
$$P = 1.0 - (R / D)$$

This is mapped directly to the tracking parameters:
1.  **Map position percentage**: $0.1 + (P \times 0.8)$
2.  **Tracking Checkpoint Steps**:
    *   $P < 0.25$ $\rightarrow$ **Cooking Aroma** (Step 0)
    *   $P \ge 0.25 \text{ and } P < 0.50$ $\rightarrow$ **Chef Speculating** (Step 1)
    *   $P \ge 0.50 \text{ and } P < 0.80$ $\rightarrow$ **Rider Speeding** (Step 2)
    *   $P \ge 0.80$ $\rightarrow$ **Arriving** (Step 3)
    *   $R = 0$ $\rightarrow$ **Delivered** (Step 4)

---

## 2. Database Columns
To ensure state persistence across application boot cycles, two fields are appended to the `orders` schema:
*   `delivery_seconds_remaining` (INTEGER): Number of seconds left until the delivery completes.
*   `total_delivery_seconds` (INTEGER): Total randomized seconds scheduled at placement.

---

## 3. Estimated Arrival Display Card
Located prominently above the simulation map inside `TrackingView`:
*   **Time String**: Formats `R` seconds as `MM:SS` (e.g. `00:45` if 45 seconds are remaining).
*   **Status Indicators**: Shows *Estimated Delivery* label accompanied by a circular progress indicator detailing the delivery timeline segment.
