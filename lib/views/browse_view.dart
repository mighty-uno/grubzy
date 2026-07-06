import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_state.dart';
import '../models/food_models.dart';
import '../theme/design_tokens.dart';

class BrowseView extends StatefulWidget {
  const BrowseView({super.key});

  @override
  State<BrowseView> createState() => _BrowseViewState();
}

class _BrowseViewState extends State<BrowseView> {
  String _activeCategory = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    
    // Filtering restaurants
    final filteredRestaurants = state.restaurants.where((r) {
      final matchesSearch = r.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.tags.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()));
      
      if (_activeCategory == 'all') {
        return matchesSearch;
      } else {
        return matchesSearch && r.tags.any((t) => t.toLowerCase() == _activeCategory);
      }
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.darkSurface,
            border: Border.all(color: AppTheme.darkBorder),
            borderRadius: AppTheme.borderMedium,
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppTheme.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search for imaginary butter chicken, biryani...',
                    hintStyle: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Categories Title
        Text('What are you craving?', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),

        // Horizontal chips
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildCategoryChip('all', 'All Foods', Icons.menu_book),
              _buildCategoryChip('biryani', 'Biryani', Icons.rice_bowl),
              _buildCategoryChip('chaat', 'Chaat', Icons.icecream),
              _buildCategoryChip('south indian', 'South Indian', Icons.flatware),
              _buildCategoryChip('burgers', 'Burgers', Icons.lunch_dining),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Restaurants grid title
        Text('Imaginary Restaurants Near You', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),

        // Restaurants Grid list
        Expanded(
          child: filteredRestaurants.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width < 600 ? 1 : 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: filteredRestaurants.length,
                  itemBuilder: (context, index) {
                    final r = filteredRestaurants[index];
                    return _buildRestaurantCard(context, r);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String categoryId, String label, IconData icon) {
    final bool isActive = _activeCategory == categoryId;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        selected: isActive,
        backgroundColor: AppTheme.darkSurface,
        selectedColor: AppTheme.primaryAccent,
        checkmarkColor: Colors.white,
        showCheckmark: false,
        avatar: Icon(icon, color: isActive ? Colors.white : AppTheme.textSecondary, size: 16),
        label: Text(
          label,
          style: GoogleFonts.inter(
            color: isActive ? Colors.white : AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        onSelected: (selected) {
          setState(() {
            _activeCategory = categoryId;
          });
        },
      ),
    );
  }

  void _openRestaurantMenu(BuildContext context, Restaurant r) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _RestaurantMenuBottomSheet(
          restaurant: r,
          onAdd: (item) {
            Navigator.pop(context); // Close the menu sheet
            _openFoodCustomizer(context, item); // Open the customizer sheet
          },
        );
      },
    );
  }

  Widget _buildRestaurantCard(BuildContext context, Restaurant r) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openRestaurantMenu(context, r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner part
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(r.imageUrl, fit: BoxFit.cover),
                  // Savings banner overlay
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: AppTheme.borderSmall,
                      ),
                      child: Text(
                        r.caloriesSavedString,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  // Discount tags
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      child: Text(
                        r.discountString,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Details part
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          r.name,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen,
                          borderRadius: AppTheme.borderSmall,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.white, size: 12),
                            const SizedBox(width: 2),
                            Text(r.rating, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${r.deliveryTime} • ₹300 for two (Virtual)', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant_menu, size: 64, color: AppTheme.textMuted),
          const SizedBox(height: 16),
          Text(
            'No restaurants match your craving!',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  // --- Show Customizer Modal Bottom Sheet / Dialog ---
  void _openFoodCustomizer(BuildContext context, MenuItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: AppTheme.borderLarge),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return FoodCustomizerSheet(item: item, scrollController: scrollController);
          },
        );
      },
    );
  }
}

class FoodCustomizerSheet extends StatefulWidget {
  final MenuItem item;
  final ScrollController scrollController;

  const FoodCustomizerSheet({super.key, required this.item, required this.scrollController});

  @override
  State<FoodCustomizerSheet> createState() => _FoodCustomizerSheetState();
}

class _FoodCustomizerSheetState extends State<FoodCustomizerSheet> {
  String _selectedSpice = 'Mild';
  final List<String> _selectedAddons = [];

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    
    return Column(
      children: [
        // Handle bar
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: AppTheme.darkBorder, borderRadius: BorderRadius.circular(2)),
        ),
        
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.item.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
        ),
        const Divider(color: AppTheme.darkBorder),
        
        Expanded(
          child: ListView(
            controller: widget.scrollController,
            children: [
              // Image
              Container(
                height: 180,
                decoration: BoxDecoration(
                  image: DecorationImage(image: NetworkImage(widget.item.imageUrl), fit: BoxFit.cover),
                ),
              ),
              
              // Description
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.item.description, style: GoogleFonts.inter(color: AppTheme.textSecondary)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Virtual Price:', style: GoogleFonts.inter(fontSize: 14)),
                        Text('₹${widget.item.price}', style: GoogleFonts.outfit(color: AppTheme.primaryAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(color: AppTheme.darkBorder),
              
              // Spice selection
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Spice Level', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppTheme.errorRed.withOpacity(0.1), borderRadius: AppTheme.borderSmall),
                          child: const Text('Required', style: TextStyle(color: AppTheme.errorRed, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildSpiceRadio('Mild'),
                        const SizedBox(width: 12),
                        _buildSpiceRadio('Indian Spicy'),
                        const SizedBox(width: 12),
                        _buildSpiceRadio('Spicy AF'),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(color: AppTheme.darkBorder),
              
              // Add-ons checklist
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Virtual Add-ons (Free)', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 12),
                    _buildAddonCheckbox('Extra Cheese'),
                    _buildAddonCheckbox('Spicy Masala Dusting'),
                    _buildAddonCheckbox('Extra Gravy'),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Footer Add button
        Container(
          padding: const EdgeInsets.all(20),
          color: AppTheme.darkSurfaceElevated,
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryAccent,
                shape: RoundedRectangleBorder(borderRadius: AppTheme.borderMedium),
              ),
              onPressed: () {
                state.addToCart(widget.item, _selectedSpice, _selectedAddons);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added ${widget.item.name} to plate!'),
                    backgroundColor: AppTheme.primaryAccent,
                  ),
                );
              },
              child: Text(
                'Add to Plate (₹${widget.item.price})',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpiceRadio(String label) {
    final bool isSelected = _selectedSpice == label;
    return Expanded(
      child: ChoiceChip(
        selected: isSelected,
        backgroundColor: Colors.transparent,
        selectedColor: AppTheme.primaryAccent.withOpacity(0.1),
        side: BorderSide(color: isSelected ? AppTheme.primaryAccent : AppTheme.darkBorder),
        label: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.primaryAccent : AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onSelected: (val) {
          if (val) setState(() => _selectedSpice = label);
        },
      ),
    );
  }

  Widget _buildAddonCheckbox(String name) {
    final bool isChecked = _selectedAddons.contains(name);
    return CheckboxListTile(
      value: isChecked,
      title: Text(name, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14)),
      secondary: const Text('+₹0', style: TextStyle(color: AppTheme.textMuted)),
      activeColor: AppTheme.primaryAccent,
      dense: true,
      contentPadding: EdgeInsets.zero,
      onChanged: (val) {
        setState(() {
          if (val == true) {
            _selectedAddons.add(name);
          } else {
            _selectedAddons.remove(name);
          }
        });
      },
    );
  }
}

class _RestaurantMenuBottomSheet extends StatefulWidget {
  final Restaurant restaurant;
  final Function(MenuItem) onAdd;

  const _RestaurantMenuBottomSheet({
    required this.restaurant,
    required this.onAdd,
  });

  @override
  State<_RestaurantMenuBottomSheet> createState() => _RestaurantMenuBottomSheetState();
}

class _RestaurantMenuBottomSheetState extends State<_RestaurantMenuBottomSheet> {
  FoodType? _selectedType;

  @override
  Widget build(BuildContext context) {
    final double sheetHeight = MediaQuery.of(context).size.height * 0.85;
    
    // Filter the menu items
    final filteredMenu = widget.restaurant.menu.where((item) {
      if (_selectedType == null) return true;
      return item.type == _selectedType;
    }).toList();

    return Container(
      height: sheetHeight,
      decoration: const BoxDecoration(
        color: AppTheme.darkBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radiusLarge),
          topRight: Radius.circular(AppTheme.radiusLarge),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Restaurant Header & Image
          Stack(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                foregroundDecoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.darkBackground,
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: Image.network(widget.restaurant.imageUrl, fit: BoxFit.cover),
              ),
              Positioned(
                top: 8,
                right: 12,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.restaurant.name,
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.successGreen,
                            borderRadius: AppTheme.borderSmall,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                widget.restaurant.rating,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${widget.restaurant.tags.join(" • ")}  |  ${widget.restaurant.deliveryTime}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          
          // Savings Promos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.savings, color: AppTheme.warningGold, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${widget.restaurant.discountString}  •  ${widget.restaurant.caloriesSavedString}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.successGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppTheme.darkBorder, height: 1),
          
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip(null, 'All'),
                const SizedBox(width: 8),
                _buildFilterChip(FoodType.veg, 'Veg 🟢'),
                const SizedBox(width: 8),
                _buildFilterChip(FoodType.vegan, 'Vegan ☘️'),
                const SizedBox(width: 8),
                _buildFilterChip(FoodType.nonVeg, 'Non-Veg 🔴'),
              ],
            ),
          ),
          const Divider(color: AppTheme.darkBorder, height: 1),
          
          // Menu Items List
          Expanded(
            child: filteredMenu.isEmpty
                ? Center(
                    child: Text(
                      'No matching dishes found.',
                      style: GoogleFonts.inter(color: AppTheme.textMuted),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: filteredMenu.length,
                    separatorBuilder: (_, __) => const Divider(color: AppTheme.darkBorder, height: 32),
                    itemBuilder: (context, index) {
                      final item = filteredMenu[index];
                      return _buildMenuItemRow(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(FoodType? type, String label) {
    final bool isSelected = _selectedType == type;
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : AppTheme.textSecondary,
        ),
      ),
      selected: isSelected,
      selectedColor: AppTheme.primaryAccent,
      backgroundColor: AppTheme.darkSurfaceElevated,
      onSelected: (selected) {
        setState(() {
          _selectedType = type;
        });
      },
    );
  }

  Widget _buildMenuItemRow(MenuItem item) {
    Color typeBorderColor;
    Color typeCircleColor;
    IconData? typeIcon;
    
    if (item.type == FoodType.veg) {
      typeBorderColor = AppTheme.successGreen;
      typeCircleColor = AppTheme.successGreen;
    } else if (item.type == FoodType.vegan) {
      typeBorderColor = AppTheme.successGreen;
      typeCircleColor = AppTheme.successGreen;
      typeIcon = Icons.eco;
    } else {
      typeBorderColor = AppTheme.errorRed;
      typeCircleColor = AppTheme.errorRed;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dish details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      border: Border.all(color: typeBorderColor, width: 1.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: typeIcon != null
                        ? Icon(typeIcon, color: typeBorderColor, size: 8)
                        : Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: typeCircleColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.type == FoodType.veg 
                        ? 'VEG' 
                        : (item.type == FoodType.vegan ? 'VEGAN' : 'NON-VEG'),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: typeBorderColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                item.name,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${item.price.toInt()}  •  ${item.kcal} kcal',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        
        // Dish image & Add button
        Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: AppTheme.borderMedium,
                  child: Image.network(
                    item.imageUrl,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: -12,
                  child: SizedBox(
                    width: 72,
                    height: 32,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryAccent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppTheme.borderSmall,
                        ),
                      ),
                      onPressed: () => widget.onAdd(item),
                      child: Text(
                        'ADD',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),
          ],
        )
      ],
    );
  }
}
