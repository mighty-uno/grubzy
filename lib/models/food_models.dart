enum FoodType { veg, vegan, nonVeg }

class MenuItem {
  final String id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final int kcal;
  final FoodType type;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.kcal,
    required this.type,
  });
}

class Restaurant {
  final String id;
  final String name;
  final String rating;
  final String deliveryTime;
  final String caloriesSavedString;
  final String discountString;
  final String imageUrl;
  final List<String> tags;
  final List<MenuItem> menu;

  Restaurant({
    required this.id,
    required this.name,
    required this.rating,
    required this.deliveryTime,
    required this.caloriesSavedString,
    required this.discountString,
    required this.imageUrl,
    required this.tags,
    required this.menu,
  });
}

class CartItem {
  final MenuItem item;
  final String spiceLevel;
  final List<String> selectedAddons;
  int quantity;

  CartItem({
    required this.item,
    required this.spiceLevel,
    required this.selectedAddons,
    this.quantity = 1,
  });

  double get totalCost => item.price * quantity;
  int get totalCalories => item.kcal * quantity;
}

class SavingsMilestone {
  final String id;
  final String name;
  final double price;
  final String description;

  SavingsMilestone({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
  });
}
