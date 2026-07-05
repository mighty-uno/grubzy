# Feature Context: Startup Splash Screen

## Overview
A styled, high-fidelity dark-themed splash screen presented during application boot. It visualizes database connection steps and active state hydration while entertaining users with loading messages.

---

## 1. UX Design & Aesthetic Specifications
*   **Color Theme**: Inherits the dark background palette (`AppTheme.darkSurface`) and premium accents (`AppTheme.primaryAccent` and `AppTheme.successGreen`).
*   **Animated Branding**: Features a scaling, pulsing brand icon (`Icons.ramen_dining`) accompanied by a glowing background accent.
*   **Simulated System Logs**: Displays text status updates that transition dynamically as different parts of the application initialize.
*   **Timing & Transition**: Mandates a minimum initialization time of 2.5 seconds to display the pulsing branding sequence, transitioning into the main viewport with a fade layout switch.

---

## 2. Initialization States & Flow

### 1. `_isInitialized` (boolean)
A state controller lock inside `AppState`. The root widget (`ZepkitApp`) monitors this boolean to switch from the splash view to the main browse dashboard.

### 2. `_loadingStatus` (string)
A text state log that updates sequentially:
1. `"Pre-heating virtual frying pans..."` — Database instantiation start.
2. `"Sourcing imaginary ingredients..."` — Loading mock menus.
3. `"Connecting to virtual food grid..."` — Attempting cloud database handshake.
4. `"Hydrating active deliveries..."` — Resuming active delivery simulations.
5. `"Dopamine levels normalized! Entering..."` — Transition finish.

---

## 3. Flutter Implementation Patterns
```dart
// main.dart routing switch
Widget build(BuildContext context) {
  final state = context.watch<AppState>();
  return MaterialApp(
    title: 'Zepkit',
    home: state.isInitialized 
        ? const HomeScreen() 
        : const SplashScreen(),
  );
}
```
*   Uses a state-driven layout switch rather than classic navigator routes to guarantee that no user action can bypass initialization.
