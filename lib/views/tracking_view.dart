import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_state.dart';
import '../theme/design_tokens.dart';

class TrackingView extends StatelessWidget {
  const TrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 850;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dopamine Delivery in Progress', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.darkSurfaceElevated,
                      border: Border.all(
                        color: state.isTrackingActive ? AppTheme.primaryAccent : AppTheme.successGreen,
                      ),
                      borderRadius: AppTheme.borderLarge,
                    ),
                    child: Text(
                      state.trackingStatusText,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: state.isTrackingActive ? AppTheme.primaryAccent : AppTheme.successGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isMobile)
            Column(
              children: [
                _buildPromoBanner(),
                const SizedBox(height: 16),
                _buildCountdownCard(state),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildPromoBanner()),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _buildCountdownCard(state)),
              ],
            ),
          const SizedBox(height: 24),
          
          if (isMobile)
            Column(
              children: [
                _buildMapSimulation(state),
                const SizedBox(height: 24),
                _buildTimelineCard(state),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 6, child: _buildMapSimulation(state)),
                const SizedBox(width: 24),
                Expanded(flex: 5, child: _buildTimelineCard(state)),
              ],
            )
        ],
      ),
    );
  }

  // --- Map Animation Node ---
  Widget _buildMapSimulation(AppState state) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: const Color(0xFF0B0B0F),
        border: Border.all(color: AppTheme.darkBorder),
        borderRadius: AppTheme.borderMedium,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 30,
            spreadRadius: -5,
          )
        ],
      ),
      child: Stack(
        children: [
          // Dotted Road Path
          Center(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 40),
              color: Colors.transparent,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Container(
                    width: 8,
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    color: AppTheme.darkBorder,
                  );
                },
              ),
            ),
          ),
          
          // Restaurant Node
          Positioned(
            left: 20,
            top: 160 - 24, // Vertically centered
            child: Column(
              children: [
                const CircleAvatar(
                  backgroundColor: AppTheme.darkSurface,
                  radius: 24,
                  child: Icon(Icons.storefront, color: AppTheme.primaryAccent, size: 24),
                ),
                const SizedBox(height: 4),
                Text('Kitchen', style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          
          // User Home Node
          Positioned(
            right: 20,
            top: 160 - 24,
            child: Column(
              children: [
                const CircleAvatar(
                  backgroundColor: AppTheme.darkSurface,
                  radius: 24,
                  child: Icon(Icons.home, color: AppTheme.successGreen, size: 24),
                ),
                const SizedBox(height: 4),
                Text('You', style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          
          // Animated Rider position
          AnimatedAlign(
            duration: const Duration(seconds: 3),
            curve: Curves.easeInOut,
            alignment: Alignment(
              -1.0 + (state.riderPositionPercentage * 2.0), // Maps 0..1 to -1..1
              0.0, // Vertically centered
            ),
            child: Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.symmetric(horizontal: 44),
              decoration: BoxDecoration(
                color: AppTheme.primaryAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryAccent.withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: const Icon(Icons.directions_run, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  // --- Step Timeline List ---
  Widget _buildTimelineCard(AppState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        border: Border.all(color: AppTheme.darkBorder),
        borderRadius: AppTheme.borderMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Live Updates from ${state.riderName}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 24),
          _buildTimelineStep(
            0,
            state.currentTrackingStep,
            'Order Placed Virtually',
            'Cooking instructions sent: "Send virtual aroma and crispy colors."',
            Icons.restaurant,
          ),
          _buildTimelineStep(
            1,
            state.currentTrackingStep,
            'Chef Speculating Food',
            'Chef Ramesh is looking at ingredients and visualizing your Butter Chicken intensely.',
            Icons.soup_kitchen,
          ),
          _buildTimelineStep(
            2,
            state.currentTrackingStep,
            'Rider ${state.riderName} Dispatched',
            'Rider ${state.riderName} is speeding past virtual speed breakers at infinite speeds.',
            Icons.motorcycle,
          ),
          _buildTimelineStep(
            3,
            state.currentTrackingStep,
            'Delivered!',
            'Take a deep, slow breath to consume the virtual essence. Saved calories.',
            Icons.notifications_active,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(int index, int currentStep, String title, String desc, IconData icon, {bool isLast = false}) {
    final bool isCompleted = currentStep > index;
    final bool isActive = currentStep == index;
    
    Color indicatorColor = AppTheme.darkBorder;
    Color iconColor = AppTheme.textMuted;
    
    if (isCompleted) {
      indicatorColor = AppTheme.successGreen;
      iconColor = Colors.white;
    } else if (isActive) {
      indicatorColor = AppTheme.primaryAccent;
      iconColor = Colors.white;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicator Left Stack
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCompleted || isActive ? indicatorColor : AppTheme.darkSurface,
                  border: Border.all(color: indicatorColor, width: 2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted ? Icons.check : icon,
                  size: 14,
                  color: iconColor,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted ? AppTheme.successGreen : AppTheme.darkBorder,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Opacity(
              opacity: isCompleted || isActive ? 1.0 : 0.3,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isActive ? AppTheme.primaryAccent : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryAccent.withOpacity(0.15),
            AppTheme.successGreen.withOpacity(0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppTheme.primaryAccent.withOpacity(0.3),
        ),
        borderRadius: AppTheme.borderMedium,
      ),
      child: Row(
        children: [
          const Icon(Icons.flash_on, color: AppTheme.primaryAccent, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lightning Fast Delivery',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'We don\'t charge a delivery fee for virtual happiness! Real savings: ₹30.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownCard(AppState state) {
    final int minutes = state.deliverySecondsRemaining ~/ 60;
    final int seconds = state.deliverySecondsRemaining % 60;
    final String timeStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        border: Border.all(color: AppTheme.darkBorder),
        borderRadius: AppTheme.borderMedium,
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  value: state.totalDeliverySeconds > 0
                      ? state.deliverySecondsRemaining / state.totalDeliverySeconds
                      : 0.0,
                  backgroundColor: AppTheme.darkBorder,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.successGreen),
                  strokeWidth: 4,
                ),
              ),
              const Icon(Icons.timer_outlined, color: AppTheme.successGreen, size: 20),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated Arrival',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  state.isTrackingActive ? timeStr : '00:00',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
