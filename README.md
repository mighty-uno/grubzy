# Grubzy: The Dopamine Delivery Simulator (Flutter Repo)

A responsive Flutter project (Web, iOS, Android) designed to satisfy the food delivery scrolling and ordering cravings of Indian users without spending real money or consuming actual calories. It redirects the dopamine loop of apps like Swiggy and Zomato into virtual progress tracking and gamified savings.

**Live Showcase Landing Page:** [grubzy.vercel.app](https://grubzy.vercel.app/)

---

## Repository Structure

The code is structured cleanly into features mapping directly from design tokens to reusable widgets:

*   **[`pubspec.yaml`](pubspec.yaml)**: Lists standard project details and external packages (`provider`, `google_fonts`, `intl`).
*   **`lib/`**:
    *   **[`main.dart`](lib/main.dart)**: Entry point. Initializes state provider and binds themes.
    *   **`theme/`**:
        *   **[`design_tokens.dart`](lib/theme/design_tokens.dart)**: Standardizes colors (Saffron Orange, Pistachio Green, Charcoal Dark Mode), gradients, rounded corners, elevations, and text structures.
    *   **`models/`**:
        *   **[`food_models.dart`](lib/models/food_models.dart)**: Data models for menu items, restaurants, plate configurations, and savings targets.
        *   **[`app_state.dart`](lib/models/app_state.dart)**: State provider managing plate selections, coin balances, XP experience levels, and live tracking timelines.
    *   **`views/`**:
        *   **[`home_screen.dart`](lib/views/home_screen.dart)**: Handles **Responsive Layout Switch**. Toggles between a Bottom Navigation Bar on Mobile (< 768dp) and a Sidebar Layout on Web/Tablets (>= 768dp).
        *   **[`browse_view.dart`](lib/views/browse_view.dart)**: Horizontal category chips and restaurant feeds. Includes customization bottom-sheets (Spice level, toppings).
        *   **[`cart_view.dart`](lib/views/cart_view.dart)**: Order summary list and checkout details. Features the **Dopamine Savings Bar** indicating real cash saved.
        *   **[`tracking_view.dart`](lib/views/tracking_view.dart)**: Live simulated map displaying horizontal `AnimatedAlign` rider movements and step progress updates.
        *   **[`dashboard_view.dart`](lib/views/dashboard_view.dart)**: Habit progress, ranks (e.g. Samosa Spectator, Momo Mediator), and unlockable savings goals (e.g. gym memberships).

---

## How to Run & Build

1.  Make sure you have [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
2.  Navigate to this project folder in your terminal:
    ```bash
    cd grubzy
    ```
3.  Install dependencies:
    ```bash
    flutter pub get
    ```
4.  Run the application on a connected device, simulator, or browser:
    ```bash
    flutter run
    ```
5.  To build a release package:
    *   **Web**: `flutter build web`
    *   **Android (APK)**: `flutter build apk`
    *   **iOS**: `flutter build ios`
