import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_state.dart';
import '../theme/design_tokens.dart';
import 'browse_view.dart';
import 'cart_view.dart';
import 'tracking_view.dart';
import 'dashboard_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Widget> _views = [
    const BrowseView(),
    const CartView(),
    const TrackingView(),
    const DashboardView(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 768;

    if (isMobile) {
      return Scaffold(
        appBar: _buildMobileAppBar(state),
        body: IndexedStack(
          index: state.activeTabIndex,
          children: _views,
        ),
        bottomNavigationBar: _buildBottomNavBar(state),
      );
    } else {
      return Scaffold(
        body: Row(
          children: [
            _buildWebSidebar(state),
            const VerticalDivider(width: 1, color: AppTheme.darkBorder),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: _views[state.activeTabIndex],
              ),
            ),
          ],
        ),
      );
    }
  }

  // --- Mobile Components ---
  PreferredSizeWidget _buildMobileAppBar(AppState state) {
    return AppBar(
      backgroundColor: AppTheme.darkSurface,
      elevation: 0,
      title: Row(
        children: [
          const Icon(Icons.ramen_dining, color: AppTheme.primaryAccent, size: 28),
          const SizedBox(width: 8),
          Text(
            'Zepkit',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w800,
              fontSize: 22,
              color: AppTheme.primaryAccent,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.coffee, color: Color(0xFFFFDD00)),
          tooltip: 'Buy Me A Coffee',
          onPressed: () => _launchSupportUrl(),
        ),
        _buildCoinsBadge(state.craveCoins),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildBottomNavBar(AppState state) {
    return NavigationBar(
      backgroundColor: AppTheme.glassBackground.withOpacity(0.9),
      elevation: 0,
      selectedIndex: state.activeTabIndex,
      onDestinationSelected: (idx) => state.setTab(idx),
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.restaurant),
          label: 'Browse',
        ),
        NavigationDestination(
          icon: Badge(
            label: Text(state.cartItemCount.toString()),
            isLabelVisible: state.cartItemCount > 0,
            child: const Icon(Icons.shopping_cart),
          ),
          label: 'Cart',
        ),
        NavigationDestination(
          icon: Badge(
            isLabelVisible: state.isTrackingActive,
            child: const Icon(Icons.local_shipping),
          ),
          label: 'Tracking',
        ),
        const NavigationDestination(
          icon: Icon(Icons.bar_chart),
          label: 'Savings',
        ),
      ],
    );
  }

  // --- Web Sidebar Component ---
  Widget _buildWebSidebar(AppState state) {
    return Container(
      width: 260,
      color: AppTheme.darkSurface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Part
          Row(
            children: [
              const Icon(Icons.ramen_dining, color: AppTheme.primaryAccent, size: 36),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                   'Zepkit',
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // User Details Panel
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.darkSurfaceElevated,
              borderRadius: AppTheme.borderMedium,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryAccent,
                  radius: 20,
                  child: Text(
                    'Z',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Zepkit Diner',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildCoinsBadge(state.craveCoins),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Navigation Menu
          _buildSidebarItem(state, 0, Icons.restaurant, 'Browse Cravings'),
          _buildSidebarItem(
            state,
            1, 
            Icons.shopping_cart, 
            'My Plate', 
            badgeCount: state.cartItemCount,
          ),
          _buildSidebarItem(
            state,
            2, 
            Icons.local_shipping, 
            'Live Tracking', 
            hasDot: state.isTrackingActive,
          ),
          _buildSidebarItem(state, 3, Icons.bar_chart, 'Savings Hub'),
          const SizedBox(height: 8),
          _buildSupportSidebarItem(),
          const Spacer(),
          
          // Location Badge
          Row(
            children: [
              const Icon(Icons.location_on, color: AppTheme.primaryAccent, size: 18),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Virtual Kitchen, India',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSidebarItem(AppState state, int index, IconData icon, String label, {int badgeCount = 0, bool hasDot = false}) {
    final bool isActive = state.activeTabIndex == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () => state.setTab(index),
        borderRadius: AppTheme.borderMedium,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.darkSurfaceElevated : Colors.transparent,
            borderRadius: AppTheme.borderMedium,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? AppTheme.textPrimary : AppTheme.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? AppTheme.textPrimary : AppTheme.textSecondary,
                  ),
                ),
              ),
              if (badgeCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: const BoxDecoration(
                    color: AppTheme.errorRed,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badgeCount.toString(),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              if (hasDot)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryAccent,
                    shape: BoxShape.circle,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoinsBadge(int coins) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.warningGold.withOpacity(0.1),
        borderRadius: AppTheme.borderLarge,
        border: Border.all(color: AppTheme.warningGold.withOpacity(0.3), style: BorderStyle.solid),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.toll, color: AppTheme.warningGold, size: 14),
          const SizedBox(width: 4),
          Text(
            '$coins CC',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppTheme.warningGold,
            ),
          )
        ],
      ),
    );
  }

  Future<void> _launchSupportUrl() async {
    final Uri url = Uri.parse('https://rzp.io/rzp/fAcZtag');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch support URL');
    }
  }

  Widget _buildSupportSidebarItem() {
    return InkWell(
      onTap: _launchSupportUrl,
      borderRadius: AppTheme.borderSmall,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        child: Row(
          children: [
            const Icon(
              Icons.coffee,
              color: Color(0xFFFFDD00),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Buy Me A Coffee',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFFDD00),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
