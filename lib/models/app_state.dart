import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'food_models.dart';
import '../services/database_service.dart';

class AppState extends ChangeNotifier {
  // --- User Stats & Gamification State ---
  int _craveCoins = 450;
  double _moneySaved = 0.0;
  int _caloriesSaved = 0;
  int _ordersPlaced = 0;
  int _xp = 25;
  int _currentLevel = 1;

  int get craveCoins => _craveCoins;
  double get moneySaved => _moneySaved;
  int get caloriesSaved => _caloriesSaved;
  int get ordersPlaced => _ordersPlaced;
  int get xp => _xp;
  int get currentLevel => _currentLevel;

  // --- Cart State ---
  final List<CartItem> _cart = [];
  List<CartItem> get cart => List.unmodifiable(_cart);

  double get cartSubtotal => _cart.fold(0.0, (sum, item) => sum + item.totalCost);
  int get cartTotalCalories => _cart.fold(0, (sum, item) => sum + item.totalCalories);
  int get cartItemCount => _cart.fold(0, (sum, item) => sum + item.quantity);

  // --- Tracking State ---
  bool _isTrackingActive = false;
  int _currentTrackingStep = 0;
  double _riderPositionPercentage = 0.1; // 0.1 to 0.9
  String _trackingStatusText = "Idle";
  Timer? _trackingTimer;
  String _riderName = "Raju";
  bool _isInitialized = false;
  String _loadingStatus = "Pre-heating virtual frying pans...";
  int _deliverySecondsRemaining = 0;
  int _totalDeliverySeconds = 0;

  bool get isTrackingActive => _isTrackingActive;
  int get currentTrackingStep => _currentTrackingStep;
  double get riderPositionPercentage => _riderPositionPercentage;
  String get trackingStatusText => _trackingStatusText;
  String get riderName => _riderName;
  bool get isInitialized => _isInitialized;
  String get loadingStatus => _loadingStatus;
  int get deliverySecondsRemaining => _deliverySecondsRemaining;
  int get totalDeliverySeconds => _totalDeliverySeconds;

  final Random _random = Random();
  final List<String> _riderNames = [
    "Raju Rocket",
    "Golu Giga",
    "Speedy Sharma",
    "Bunty Bullet",
    "Pappu Pilot",
    "Chintu Cheetah",
    "Vicky Velocity",
    "Bablu Booster",
  ];

  String _getRandomRiderName() => _riderNames[_random.nextInt(_riderNames.length)];

  // --- Navigation State ---
  int _activeTabIndex = 0;
  int get activeTabIndex => _activeTabIndex;

  void setTab(int index) {
    _activeTabIndex = index;
    notifyListeners();
  }

  // --- Database-Driven Catalog ---
  List<Restaurant> _restaurants = [];
  List<Restaurant> get restaurants => _restaurants;

  final List<SavingsMilestone> milestones = [
    SavingsMilestone(id: "mil1", name: "A Real Premium Coffee", price: 300, description: "Treat yourself to a real Starbucks coffee with saved cash."),
    SavingsMilestone(id: "mil2", name: "Movie Ticket & Popcorn", price: 700, description: "Book a real ticket at your local multiplex."),
    SavingsMilestone(id: "mil3", name: "New Sleek T-shirt", price: 1200, description: "A fresh clothing item to wear out."),
    SavingsMilestone(id: "mil4", name: "Monthly Gym Membership", price: 2000, description: "Invest in real physical fitness."),
    SavingsMilestone(id: "mil5", name: "Wireless Noise-Canceling Buds", price: 4000, description: "High-quality audio saved purely from virtual food!")
  ];

  String get levelTitle {
    if (_currentLevel >= 5) return "Biryani Buddha";
    if (_currentLevel >= 4) return "Dosa Dominator";
    if (_currentLevel >= 3) return "Chaat Challenger";
    if (_currentLevel >= 2) return "Momo Mediator";
    return "Samosa Spectator";
  }

  AppState() {
    _loadFromDatabase();
  }

  Future<void> _loadFromDatabase() async {
    try {
      _loadingStatus = "Pre-heating virtual frying pans...";
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 600));

      final dbHelper = DatabaseService.instance;

      // 1. Load User Stats
      _loadingStatus = "Sourcing imaginary ingredients...";
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 600));

      final statsRows = await dbHelper.query("SELECT * FROM user_stats WHERE id = 'current_user'");
      if (statsRows.isNotEmpty) {
        final row = statsRows[0];
        _craveCoins = row['crave_coins'] as int;
        _moneySaved = (row['money_saved'] as num).toDouble();
        _caloriesSaved = row['calories_saved'] as int;
        _ordersPlaced = row['orders_placed'] as int;
        _xp = row['xp'] as int;
        _currentLevel = row['current_level'] as int;
      }

      // 2. Load Restaurants & Menu Items
      _loadingStatus = "Connecting to virtual food grid...";
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 600));

      final restaurantRows = await dbHelper.query("SELECT * FROM restaurants");
      final List<Restaurant> loadedRestaurants = [];

      for (var rRow in restaurantRows) {
        final rId = rRow['id'] as String;
        final itemRows = await dbHelper.query("SELECT * FROM menu_items WHERE restaurant_id = ?", [rId]);
        final List<MenuItem> menu = itemRows.map((iRow) {
          FoodType itemType = FoodType.veg;
          final String typeStr = iRow['type'] as String;
          if (typeStr == 'vegan') {
            itemType = FoodType.vegan;
          } else if (typeStr == 'nonVeg') {
            itemType = FoodType.nonVeg;
          }

          return MenuItem(
            id: iRow['id'] as String,
            name: iRow['name'] as String,
            price: (iRow['price'] as num).toDouble(),
            description: iRow['description'] as String? ?? "",
            imageUrl: iRow['image_url'] as String? ?? "",
            kcal: iRow['kcal'] as int,
            type: itemType,
          );
        }).toList();

        loadedRestaurants.add(Restaurant(
          id: rId,
          name: rRow['name'] as String,
          rating: rRow['rating'] as String? ?? "4.0",
          deliveryTime: rRow['delivery_time'] as String? ?? "15 mins",
          caloriesSavedString: rRow['calories_saved_string'] as String? ?? "",
          discountString: rRow['discount_string'] as String? ?? "",
          imageUrl: rRow['image_url'] as String? ?? "",
          tags: (rRow['tags'] as String? ?? "").split(','),
          menu: menu,
        ));
      }

      _restaurants = loadedRestaurants;

      // 3. Load Active Order
      _loadingStatus = "Hydrating active deliveries...";
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 600));

      final orderRows = await dbHelper.query(
        "SELECT * FROM orders WHERE status != 'delivered' ORDER BY created_at DESC LIMIT 1"
      );
      if (orderRows.isNotEmpty) {
        final activeOrder = orderRows[0];
        _isTrackingActive = true;
        _riderName = activeOrder['rider_name'] as String? ?? "Raju";
        _deliverySecondsRemaining = activeOrder['delivery_seconds_remaining'] as int? ?? 60;
        _totalDeliverySeconds = activeOrder['total_delivery_seconds'] as int? ?? 60;

        _resumeTrackingSimulation(activeOrder['id'] as String, activeOrder['calories_saved'] as int);
      }

      _loadingStatus = "Dopamine levels normalized! Entering...";
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 500));

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading from database: $e");
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _saveUserStatsToDatabase() async {
    try {
      await DatabaseService.instance.executeWrite(
        "UPDATE user_stats SET crave_coins = ?, money_saved = ?, calories_saved = ?, orders_placed = ?, xp = ?, current_level = ? WHERE id = 'current_user'",
        [_craveCoins, _moneySaved, _caloriesSaved, _ordersPlaced, _xp, _currentLevel]
      );
    } catch (e) {
      debugPrint("Error saving user stats: $e");
    }
  }

  String _getTrackingTextForStatus(String status) {
    switch (status) {
      case 'placed':
        return "Cooking Aroma...";
      case 'cooking':
        return "Chef Speculating...";
      case 'rider_pickup':
        return "Raju Speeding...";
      case 'delivering':
        return "Arrived!";
      default:
        return "Virtually Consumed!";
    }
  }

  int _getTrackingStepForStatus(String status) {
    switch (status) {
      case 'placed':
        return 0;
      case 'cooking':
        return 1;
      case 'rider_pickup':
        return 2;
      case 'delivering':
        return 3;
      default:
        return 4;
    }
  }

  double _getRiderPercentageForStep(int step) {
    switch (step) {
      case 0:
        return 0.1;
      case 1:
        return 0.3;
      case 2:
        return 0.6;
      case 3:
        return 0.9;
      default:
        return 1.0;
    }
  }

  // --- Cart Actions ---
  void addToCart(MenuItem item, String spice, List<String> addons) {
    int index = _cart.indexWhere((c) => 
      c.item.id == item.id && 
      c.spiceLevel == spice && 
      listEquals(c.selectedAddons, addons)
    );

    if (index >= 0) {
      _cart[index].quantity++;
    } else {
      _cart.add(CartItem(item: item, spiceLevel: spice, selectedAddons: addons));
    }
    
    addXP(10);
    notifyListeners();
  }

  void adjustQuantity(int idx, int delta) {
    _cart[idx].quantity += delta;
    if (_cart[idx].quantity <= 0) {
      _cart.removeAt(idx);
    }
    notifyListeners();
  }

  // --- XP Progression ---
  void addXP(int amount) {
    _xp += amount;
    int needed = _currentLevel * 100;
    if (_xp >= needed) {
      _xp -= needed;
      _currentLevel++;
    }
    _saveUserStatsToDatabase();
    notifyListeners();
  }

  // --- Simulated Delivery Timer ---
  void placeSimulatedOrder() {
    if (_cart.isEmpty) return;

    final double orderSavings = cartSubtotal;
    final int orderCalories = cartTotalCalories;

    _moneySaved += orderSavings;
    _caloriesSaved += orderCalories;
    _ordersPlaced += 1;
    _craveCoins += 30; // reward currency

    String restaurantName = "Bhukkad Express";
    for (var r in _restaurants) {
      if (r.menu.any((m) => m.id == _cart.first.item.id)) {
        restaurantName = r.name;
        break;
      }
    }

    _riderName = _getRandomRiderName();
    _totalDeliverySeconds = 40 + _random.nextInt(30); // 40 to 70 seconds
    _deliverySecondsRemaining = _totalDeliverySeconds;

    final String orderId = DateTime.now().millisecondsSinceEpoch.toString();
    final itemsList = _cart.map((c) => {
      'id': c.item.id,
      'name': c.item.name,
      'price': c.item.price,
      'quantity': c.quantity,
      'spice': c.spiceLevel,
      'addons': c.selectedAddons,
    }).toList();

    // Insert order to database
    DatabaseService.instance.executeWrite(
      "INSERT INTO orders (id, restaurant_name, items_json, subtotal, discount, delivery_fee, total, status, calories_saved, created_at, rider_name, delivery_seconds_remaining, total_delivery_seconds) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      [
        orderId,
        restaurantName,
        jsonEncode(itemsList),
        orderSavings,
        orderSavings,
        0.0,
        0.0,
        "placed",
        orderCalories,
        DateTime.now().toIso8601String(),
        _riderName,
        _deliverySecondsRemaining,
        _totalDeliverySeconds
      ]
    );

    _saveUserStatsToDatabase();

    _cart.clear();
    notifyListeners();
    
    startTracking(orderId, orderCalories);
  }

  void startTracking(String orderId, int calories) {
    _isTrackingActive = true;
    _currentTrackingStep = 0;
    _riderPositionPercentage = 0.1;
    _trackingStatusText = "Cooking Aroma...";
    notifyListeners();

    _runTrackingStep(orderId, calories);
  }

  void _resumeTrackingSimulation(String orderId, int calories) {
    _runTrackingStep(orderId, calories);
  }

  void _runTrackingStep(String orderId, int calories) {
    _trackingTimer?.cancel();
    if (!_isTrackingActive) return;

    _trackingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isTrackingActive) {
        timer.cancel();
        return;
      }

      if (_deliverySecondsRemaining > 0) {
        _deliverySecondsRemaining--;
      }

      String newStatus = 'cooking';

      if (_deliverySecondsRemaining <= 0) {
        _isTrackingActive = false;
        _currentTrackingStep = 4;
        _riderPositionPercentage = 0.9;
        _trackingStatusText = "Virtually Consumed!";
        addXP(40);
        newStatus = 'delivered';
        timer.cancel();
      } else {
        // Calculate progress percentage
        double progress = 1.0 - (_deliverySecondsRemaining / _totalDeliverySeconds);
        // Bind rider map coordinates
        _riderPositionPercentage = 0.1 + (progress * 0.8);

        // Bind status and step checkpoints
        if (progress < 0.25) {
          _currentTrackingStep = 0;
          _trackingStatusText = "Cooking Aroma...";
          newStatus = 'placed';
        } else if (progress >= 0.25 && progress < 0.50) {
          _currentTrackingStep = 1;
          _trackingStatusText = "Chef Speculating...";
          newStatus = 'cooking';
        } else if (progress >= 0.50 && progress < 0.80) {
          _currentTrackingStep = 2;
          _trackingStatusText = "$_riderName Speeding...";
          newStatus = 'rider_pickup';
        } else {
          _currentTrackingStep = 3;
          _trackingStatusText = "Arrived!";
          newStatus = 'delivering';
        }
      }

      // Update database with countdown progress
      DatabaseService.instance.executeWrite(
        "UPDATE orders SET status = ?, delivery_seconds_remaining = ? WHERE id = ?",
        [newStatus, _deliverySecondsRemaining, orderId]
      );

      notifyListeners();
    });
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    super.dispose();
  }
}
