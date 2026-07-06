import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  // --- Configuration constants for optional Turso remote database integration ---
  // Leave _tursoUrl empty to use local SQLite only.
  static const String _tursoUrl = "https://zepkit-mighty-uno.aws-ap-south-1.turso.io";
  static const String _tursoToken = "eyJhbGciOiJFZERTQSIsInR5cCI6IkpXVCJ9.eyJhIjoicnciLCJpYXQiOjE3ODMyNzIyMzMsImlkIjoiMDE5ZjMzNDktMDQwMS03MDEwLThlNzMtYjM3OTExMDk5YzI1Iiwia2lkIjoieFZRZFYzRV9sY0pBbHhnbnFmZ3FZREp1eGJCOXl1RGUwUEcxRWMzT1hMNCIsInJpZCI6ImM0MTRjNWUwLTQzNWMtNGRiYS1iYTYzLWM1NzNkZmViODJjZCJ9.eM-jUW9wGWPvS23SzYyke6xjhnc4xuGhu307wlGdxmQhW5pvRQ5cipP7Io4KAtufKpnappdMn8vtdjhp5EJ1BA";

  DatabaseService._init();

  bool get isTursoConfigured => _tursoUrl.isNotEmpty && _tursoToken.isNotEmpty;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('grubzy.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onOpen: (db) async {
        await db.rawUpdate(
          "UPDATE restaurants SET image_url = REPLACE(image_url, 'df056fb4ce78', 'df0568f70950') WHERE image_url LIKE '%df056fb4ce78%'"
        );
        await db.rawUpdate(
          "UPDATE menu_items SET image_url = REPLACE(image_url, 'df056fb4ce78', 'df0568f70950') WHERE image_url LIKE '%df056fb4ce78%'"
        );
        try {
          await db.execute("ALTER TABLE orders ADD COLUMN rider_name TEXT");
        } catch (_) {}
        try {
          await db.execute("ALTER TABLE orders ADD COLUMN delivery_seconds_remaining INTEGER");
        } catch (_) {}
        try {
          await db.execute("ALTER TABLE orders ADD COLUMN total_delivery_seconds INTEGER");
        } catch (_) {}
        try {
          final List<Map<String, dynamic>> resCount = await db.query('restaurants', where: "id IN ('r6', 'r7', 'r8')");
          if (resCount.length < 3) {
            await _seedInternationalRestaurants(db);
          }
        } catch (_) {}
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE restaurants (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        rating TEXT,
        delivery_time TEXT,
        calories_saved_string TEXT,
        discount_string TEXT,
        image_url TEXT,
        tags TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE menu_items (
        id TEXT PRIMARY KEY,
        restaurant_id TEXT NOT NULL,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        description TEXT,
        image_url TEXT,
        kcal INTEGER NOT NULL,
        type TEXT NOT NULL,
        FOREIGN KEY (restaurant_id) REFERENCES restaurants (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        restaurant_name TEXT NOT NULL,
        items_json TEXT NOT NULL,
        subtotal REAL NOT NULL,
        discount REAL NOT NULL,
        delivery_fee REAL NOT NULL,
        total REAL NOT NULL,
        status TEXT NOT NULL,
        calories_saved INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        rider_name TEXT,
        delivery_seconds_remaining INTEGER,
        total_delivery_seconds INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE user_stats (
        id TEXT PRIMARY KEY,
        crave_coins INTEGER NOT NULL,
        money_saved REAL NOT NULL,
        calories_saved INTEGER NOT NULL,
        orders_placed INTEGER NOT NULL,
        xp INTEGER NOT NULL,
        current_level INTEGER NOT NULL
      )
    ''');

    // Insert default user stats
    await db.insert('user_stats', {
      'id': 'current_user',
      'crave_coins': 450,
      'money_saved': 0.0,
      'calories_saved': 0,
      'orders_placed': 0,
      'xp': 25,
      'current_level': 1,
    });

    // Seed the database
    await _seedDatabase(db);
  }

  Future<void> _seedDatabase(Database db) async {
    final restaurantsData = [
      {
        'id': 'r1',
        'name': 'Delhi Durbar (Imaginary)',
        'rating': '4.8',
        'delivery_time': '15 mins',
        'calories_saved_string': 'Save ~800 kcal',
        'discount_string': '100% OFF (MAX ₹0)',
        'image_url': 'https://images.unsplash.com/photo-1633945274405-b6c8069047b0?auto=format&fit=crop&w=400&q=80',
        'tags': 'Mughlai,Biryani,North Indian',
      },
      {
        'id': 'r2',
        'name': 'Dosa Express (Virtual)',
        'rating': '4.6',
        'delivery_time': '12 mins',
        'calories_saved_string': 'Save ~400 kcal',
        'discount_string': 'Free Virtual Chutney',
        'image_url': 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=400&q=80',
        'tags': 'South Indian,Healthy-ish',
      },
      {
        'id': 'r3',
        'name': 'The Green Garden (Vegan & Veg)',
        'rating': '4.7',
        'delivery_time': '18 mins',
        'calories_saved_string': 'Save ~600 kcal',
        'discount_string': '100% Cruelty-Free Discount',
        'image_url': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=400&q=80',
        'tags': 'Healthy-ish,Salads,Vegan',
      },
      {
        'id': 'r4',
        'name': 'Chaat Corner (Veg & Vegan)',
        'rating': '4.5',
        'delivery_time': '10 mins',
        'calories_saved_string': 'Save ~350 kcal',
        'discount_string': 'Unlimited Virtual Sukha Puri',
        'image_url': 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=400&q=80',
        'tags': 'Street Food,Chaat,Veg',
      },
      {
        'id': 'r5',
        'name': 'Burger Lab (Non-Veg & Veg)',
        'rating': '4.9',
        'delivery_time': '20 mins',
        'calories_saved_string': 'Save ~950 kcal',
        'discount_string': 'Infinite Virtual Extra Cheese',
        'image_url': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=400&q=80',
        'tags': 'Burgers,Fast Food,American',
      }
    ];

    for (var r in restaurantsData) {
      await db.insert('restaurants', r);
    }

    final menuItemsData = [
      // Delhi Durbar
      {
        'id': 'm1',
        'restaurant_id': 'r1',
        'name': 'Dopamine Chicken Biryani',
        'price': 380.0,
        'description': 'Aromatic basmati rice cooked with succulent imaginary chicken and secret spices. Zero physical calories, infinite cognitive pleasure.',
        'image_url': 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=400&q=80',
        'kcal': 850,
        'type': 'nonVeg',
      },
      {
        'id': 'm2',
        'restaurant_id': 'r1',
        'name': 'Fake Butter Chicken & Garlic Naan',
        'price': 420.0,
        'description': 'Rich, creamy simulated tomato gravy with tender pieces of virtual chicken, served with 2 pieces of virtual garlic naan.',
        'image_url': 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&fit=crop&w=400&q=80',
        'kcal': 1100,
        'type': 'nonVeg',
      },
      {
        'id': 'm3',
        'restaurant_id': 'r1',
        'name': 'Paneer Tikka (Ghost)',
        'price': 290.0,
        'description': 'Cubes of imaginary paneer marinated in virtual yogurt and spices, grilled to perfection in a simulated tandoor.',
        'image_url': 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?auto=format&fit=crop&w=400&q=80',
        'kcal': 450,
        'type': 'veg',
      },
      // Dosa Express
      {
        'id': 'm4',
        'restaurant_id': 'r2',
        'name': 'Aroma Masala Dosa',
        'price': 180.0,
        'description': 'Super crispy golden crepe made of fermented rice batter, stuffed with a spiced imaginary potato filling.',
        'image_url': 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=400&q=80',
        'kcal': 380,
        'type': 'veg',
      },
      {
        'id': 'm5',
        'restaurant_id': 'r2',
        'name': 'Simulated Idli Sambar (2 Pcs)',
        'price': 110.0,
        'description': 'Steamed soft fluffy rice cakes served with hot imaginary lentil soup (sambar) and virtual coconut chutney.',
        'image_url': 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=400&q=80',
        'kcal': 220,
        'type': 'vegan',
      },
      // The Green Garden
      {
        'id': 'm6',
        'restaurant_id': 'r3',
        'name': 'Zero-Calorie Avocado Toast',
        'price': 240.0,
        'description': 'Toasted sourdough bread topped with creamy virtual avocado mash, red pepper flakes, and a squeeze of simulated lemon.',
        'image_url': 'https://images.unsplash.com/photo-1541532713592-79a0317b6b77?auto=format&fit=crop&w=400&q=80',
        'kcal': 290,
        'type': 'vegan',
      },
      {
        'id': 'm7',
        'restaurant_id': 'r3',
        'name': 'Simulated Quinoa Power Bowl',
        'price': 280.0,
        'description': 'A nutrient-rich mix of virtual red quinoa, steamed kale, cherry tomatoes, and cucumber, drizzled with ghost tahini dressing.',
        'image_url': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=400&q=80',
        'kcal': 340,
        'type': 'vegan',
      },
      {
        'id': 'm8',
        'restaurant_id': 'r3',
        'name': 'Mirage Tofu Stir-Fry',
        'price': 260.0,
        'description': 'Crispy virtual tofu cubes tossed with broccoli, bell peppers, and snap peas in a simulated light soy glaze.',
        'image_url': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=400&q=80',
        'kcal': 310,
        'type': 'vegan',
      },
      {
        'id': 'm9',
        'restaurant_id': 'r3',
        'name': 'Hummus & Falafel Plate (Ghost)',
        'price': 220.0,
        'description': 'Creamy virtual chickpea hummus served with 3 pieces of golden imaginary falafel and warm pita bread.',
        'image_url': 'https://images.unsplash.com/photo-1547058886-af77813be045?auto=format&fit=crop&w=400&q=80',
        'kcal': 480,
        'type': 'veg',
      },
      // Chaat Corner
      {
        'id': 'm10',
        'restaurant_id': 'r4',
        'name': 'Ghost Golgappa (Pani Puri)',
        'price': 90.0,
        'description': '6 crispy hollow puris stuffed with potatoes and loaded with spicy-sweet virtual flavored water. Pop it whole!',
        'image_url': 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=400&q=80',
        'kcal': 180,
        'type': 'vegan',
      },
      {
        'id': 'm11',
        'restaurant_id': 'r4',
        'name': 'Dopamine Dahi Puri',
        'price': 130.0,
        'description': 'Crispy puris filled with potatoes, sweet virtual yogurt, tangy tamarind chutney, and topped with thin sev.',
        'image_url': 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=400&q=80',
        'kcal': 320,
        'type': 'veg',
      },
      {
        'id': 'm12',
        'restaurant_id': 'r4',
        'name': 'Simulated Samosa Chaat',
        'price': 150.0,
        'description': 'Deconstructed hot samosa smothered in spicy virtual chickpea curry, sweet yogurt, chutneys, and fresh coriander.',
        'image_url': 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=400&q=80',
        'kcal': 410,
        'type': 'veg',
      },
      // Burger Lab
      {
        'id': 'm13',
        'restaurant_id': 'r5',
        'name': 'Simulated Double Beef Smash',
        'price': 360.0,
        'description': 'Two flame-grilled virtual beef patties smashed thin, topped with cheddar cheese, pickles, and signature ghost sauce.',
        'image_url': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=400&q=80',
        'kcal': 890,
        'type': 'nonVeg',
      },
      {
        'id': 'm14',
        'restaurant_id': 'r5',
        'name': 'Dopamine Crispy Chicken Burger',
        'price': 320.0,
        'description': 'Juicy buttermilk-fried virtual chicken thigh topped with shredded lettuce and creamy simulated garlic aioli.',
        'image_url': 'https://images.unsplash.com/photo-1625813506062-0aeb1d7a094b?auto=format&fit=crop&w=400&q=80',
        'kcal': 780,
        'type': 'nonVeg',
      },
      {
        'id': 'm15',
        'restaurant_id': 'r5',
        'name': 'Mirage Spicy Paneer Burger',
        'price': 270.0,
        'description': 'A crispy, spicy breaded virtual paneer patty layered with fresh lettuce, onions, and tandoori spread.',
        'image_url': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=400&q=80',
        'kcal': 620,
        'type': 'veg',
      },
      {
        'id': 'm16',
        'restaurant_id': 'r5',
        'name': 'Vegan Beyond Patty Burger',
        'price': 380.0,
        'description': '100% plant-based virtual patty grilled to perfection, served with vegan mayo, lettuce, tomatoes on a toasted gluten-free bun.',
        'image_url': 'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?auto=format&fit=crop&w=400&q=80',
        'kcal': 450,
        'type': 'vegan',
      }
    ];

    for (var m in menuItemsData) {
      await db.insert('menu_items', m);
    }

    await _seedInternationalRestaurants(db);
  }

  Future<void> _seedInternationalRestaurants(Database db) async {
    final newRes = [
      {
        'id': 'r6',
        'name': 'La Trattoria (Virtual)',
        'rating': '4.9',
        'delivery_time': '22 mins',
        'calories_saved_string': 'Save ~780 kcal',
        'discount_string': '100% OFF (MAX ₹0)',
        'image_url': 'https://images.unsplash.com/photo-1537047902294-62a40c20a6ae?auto=format&fit=crop&w=400&q=80',
        'tags': 'Italian,Pasta,Pizza',
      },
      {
        'id': 'r7',
        'name': 'Kyoto Sushi (Ghost)',
        'rating': '4.8',
        'delivery_time': '16 mins',
        'calories_saved_string': 'Save ~420 kcal',
        'discount_string': 'Free Simulated Wasabi',
        'image_url': 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&w=400&q=80',
        'tags': 'Japanese,Sushi,Healthy-ish',
      },
      {
        'id': 'r8',
        'name': 'Cantina Mexicana (Mirage)',
        'rating': '4.7',
        'delivery_time': '20 mins',
        'calories_saved_string': 'Save ~790 kcal',
        'discount_string': 'Unlimited Virtual Tacos Discount',
        'image_url': 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?auto=format&fit=crop&w=400&q=80',
        'tags': 'Mexican,Tacos,Street Food',
      }
    ];

    for (var r in newRes) {
      await db.insert('restaurants', r, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    final newItems = [
      // La Trattoria
      {
        'id': 'm17',
        'restaurant_id': 'r6',
        'name': 'Ghost Truffle Fettuccine',
        'price': 490.0,
        'description': 'Silky fettuccine tossed in a rich butter sauce with imaginary white truffles. Rich in imaginary aroma.',
        'image_url': 'https://images.unsplash.com/photo-1645112411341-6c4fd023714a?auto=format&fit=crop&w=400&q=80',
        'kcal': 780,
        'type': 'veg',
      },
      {
        'id': 'm18',
        'restaurant_id': 'r6',
        'name': 'Mirage Margherita Pizza',
        'price': 360.0,
        'description': 'Neapolitan thin crust topped with simulated mozzarella, sweet pomodoro tomatoes, and virtual basil leaves.',
        'image_url': 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?auto=format&fit=crop&w=400&q=80',
        'kcal': 640,
        'type': 'veg',
      },
      {
        'id': 'm19',
        'restaurant_id': 'r6',
        'name': 'Tiramisu Illusion',
        'price': 240.0,
        'description': 'Layered sponge fingers soaked in coffee, loaded with virtual mascarpone cream, and dusted with cocoa.',
        'image_url': 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?auto=format&fit=crop&w=400&q=80',
        'kcal': 450,
        'type': 'veg',
      },
      // Kyoto Sushi
      {
        'id': 'm20',
        'restaurant_id': 'r7',
        'name': 'Dopamine Salmon Sushi Platter',
        'price': 550.0,
        'description': 'A beautifully curated arrangement of virtual fresh salmon nigiri, sashimi, and maki rolls.',
        'image_url': 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&w=400&q=80',
        'kcal': 420,
        'type': 'nonVeg',
      },
      {
        'id': 'm21',
        'restaurant_id': 'r7',
        'name': 'Simulated Spicy Ramen',
        'price': 380.0,
        'description': 'Rich, slow-simmered virtual broth with chewy noodles, topped with imaginary egg, bamboo shoots, and green onion.',
        'image_url': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=400&q=80',
        'kcal': 680,
        'type': 'nonVeg',
      },
      {
        'id': 'm22',
        'restaurant_id': 'r7',
        'name': 'Ghost Avocado Maki (8 Pcs)',
        'price': 220.0,
        'description': 'Sushi rolls wrapped in toasted nori, stuffed with virtual avocado and sesame seeds.',
        'image_url': 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&w=400&q=80',
        'kcal': 250,
        'type': 'vegan',
      },
      // Cantina Mexicana
      {
        'id': 'm23',
        'restaurant_id': 'r8',
        'name': 'Simulated Birria Tacos (3 Pcs)',
        'price': 340.0,
        'description': 'Crispy virtual corn tortillas stuffed with slow-cooked shredded beef and melted cheese, served with hot consommé.',
        'image_url': 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?auto=format&fit=crop&w=400&q=80',
        'kcal': 790,
        'type': 'nonVeg',
      },
      {
        'id': 'm24',
        'restaurant_id': 'r8',
        'name': 'Ghost Quesadilla Gigante',
        'price': 290.0,
        'description': 'Large flour tortilla packed with simulated monterey jack cheese, onions, peppers, and spicy virtual salsa.',
        'image_url': 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?auto=format&fit=crop&w=400&q=80',
        'kcal': 540,
        'type': 'veg',
      },
      {
        'id': 'm25',
        'restaurant_id': 'r8',
        'name': 'Dopamine Churros with Caramel',
        'price': 180.0,
        'description': 'Crisp fried imaginary dough pastry dusted in cinnamon sugar, served with a rich virtual caramel dipping sauce.',
        'image_url': 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?auto=format&fit=crop&w=400&q=80',
        'kcal': 420,
        'type': 'veg',
      }
    ];

    for (var m in newItems) {
      await db.insert('menu_items', m, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  // --- Hybrid Database Query Execution Logic ---

  /// Helper to convert a local value to a Turso pipeline argument map.
  List<Map<String, dynamic>> _mapArgsForTurso(List<dynamic>? args) {
    if (args == null) return [];
    return args.map((arg) {
      if (arg == null) {
        return {"type": "null"};
      } else if (arg is int) {
        return {"type": "integer", "value": arg.toString()};
      } else if (arg is double) {
        return {"type": "float", "value": arg};
      } else if (arg is bool) {
        return {"type": "integer", "value": arg ? "1" : "0"};
      } else {
        return {"type": "text", "value": arg.toString()};
      }
    }).toList();
  }

  /// Parses rows out of Turso's execute response block
  List<Map<String, dynamic>> _parseTursoExecuteResponse(Map<String, dynamic> result) {
    final List<Map<String, dynamic>> rowMaps = [];
    final cols = result['cols'] as List<dynamic>;
    final rows = result['rows'] as List<dynamic>;
    for (var r in rows) {
      final Map<String, dynamic> rowMap = {};
      for (int i = 0; i < cols.length; i++) {
        final colName = cols[i]['name'] as String;
        rowMap[colName] = r[i];
      }
      rowMaps.add(rowMap);
    }
    return rowMaps;
  }

  /// Executes a SELECT/Read query. Tries Turso first, falls back to SQLite.
  Future<List<Map<String, dynamic>>> query(String sql, [List<dynamic>? args]) async {
    if (isTursoConfigured) {
      try {
        final uri = Uri.parse('$_tursoUrl/v2/pipeline');
        final response = await http.post(
          uri,
          headers: {
            'Authorization': 'Bearer $_tursoToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "requests": [
              {
                "type": "execute",
                "stmt": {
                  "sql": sql,
                  if (args != null && args.isNotEmpty) "args": _mapArgsForTurso(args)
                }
              },
              {
                "type": "close"
              }
            ]
          }),
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          final results = decoded['results'] as List<dynamic>;
          if (results.isNotEmpty && results[0]['type'] == 'ok') {
            final executeResult = results[0]['result'];
            return _parseTursoExecuteResponse(executeResult);
          }
        }
      } catch (e) {
        debugPrint("Turso Query Exception: $e. Falling back to local SQLite.");
      }
    }

    // SQLite Fallback / Default
    final db = await database;
    return await db.rawQuery(sql, args);
  }

  /// Executes an INSERT/UPDATE/DELETE write query. Writes to SQLite, and replicates to Turso.
  Future<int> executeWrite(String sql, [List<dynamic>? args]) async {
    // 1. Write locally to SQLite first
    final db = await database;
    final int localResult = await db.rawUpdate(sql, args);

    // 2. Replicate to Turso asynchronously/synchronously
    if (isTursoConfigured) {
      try {
        final uri = Uri.parse('$_tursoUrl/v2/pipeline');
        final response = await http.post(
          uri,
          headers: {
            'Authorization': 'Bearer $_tursoToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "requests": [
              {
                "type": "execute",
                "stmt": {
                  "sql": sql,
                  if (args != null && args.isNotEmpty) "args": _mapArgsForTurso(args)
                }
              },
              {
                "type": "close"
              }
            ]
          }),
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode != 200) {
          debugPrint("Turso Replicate Failed: HTTP ${response.statusCode}");
        }
      } catch (e) {
        debugPrint("Turso Write Replicate Exception: $e.");
      }
    }

    return localResult;
  }
}
