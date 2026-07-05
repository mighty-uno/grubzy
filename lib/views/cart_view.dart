import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_state.dart';
import '../theme/design_tokens.dart';
import 'order_success_overlay.dart';
import 'payment_dialog.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 900;

    if (state.cart.isEmpty) {
      return _buildEmptyState(context);
    }

    if (isMobile) {
      return SingleChildScrollView(
        child: Column(
          children: [
            _buildCartItemsList(state),
            const SizedBox(height: 24),
            _buildDopamineSavingsCard(state),
            const SizedBox(height: 20),
            _buildReceiptCard(context, state),
          ],
        ),
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: SingleChildScrollView(child: _buildCartItemsList(state)),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildDopamineSavingsCard(state),
                  const SizedBox(height: 20),
                  _buildReceiptCard(context, state),
                ],
              ),
            ),
          )
        ],
      );
    }
  }

  // --- Helper Widgets ---
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_basket, size: 64, color: AppTheme.textMuted),
          const SizedBox(height: 16),
          Text(
            'Your plate is empty!',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Go back and add some virtual food to satisfy your cravings.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryAccent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: AppTheme.borderMedium),
            ),
            onPressed: () {
              // Direct navigation would require a tab controller, for now we prompt
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select the Browse tab in sidebar/navigation bar')),
              );
            },
            child: const Text('Browse Restaurants', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildCartItemsList(AppState state) {
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
          Text('Your Virtual Plate', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.cart.length,
            separatorBuilder: (_, __) => const Divider(color: AppTheme.darkBorder, height: 24),
            itemBuilder: (context, idx) {
              final c = state.cart[idx];
              return Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: AppTheme.borderSmall,
                      image: DecorationImage(image: NetworkImage(c.item.imageUrl), fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.item.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(
                          'Spice: ${c.spiceLevel} ${c.selectedAddons.isNotEmpty ? "• Add-ons: ${c.selectedAddons.join(', ')}" : ""}',
                          style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.darkSurfaceElevated,
                      borderRadius: AppTheme.borderSmall,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          iconSize: 16,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                          icon: const Icon(Icons.remove, color: AppTheme.primaryAccent),
                          onPressed: () => state.adjustQuantity(idx, -1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            c.quantity.toString(),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          iconSize: 16,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                          icon: const Icon(Icons.add, color: AppTheme.primaryAccent),
                          onPressed: () => state.adjustQuantity(idx, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('₹${c.totalCost.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDopamineSavingsCard(AppState state) {
    final double subtotal = state.cartSubtotal;
    final double progress = (subtotal / 1000.0).clamp(0.0, 1.0);
    
    String message = "Add items to calculate savings!";
    if (subtotal < 300) {
      message = "Awesome! That's a premium coffee saved. Keep it up!";
    } else if (subtotal < 600) {
      message = "Incredible! You could buy a real movie ticket with that.";
    } else {
      message = "Slayer! You saved massive delivery markups. Heroic!";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.glassGlowGradient,
        border: Border.all(color: AppTheme.successGreen.withOpacity(0.3)),
        borderRadius: AppTheme.borderMedium,
        boxShadow: [
          BoxShadow(
            color: AppTheme.successGreen.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Real Money Saved Today',
                style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '₹${subtotal.toInt()}',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.successGreen,
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.darkSurfaceElevated,
              color: AppTheme.successGreen,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
          )
        ],
      ),
    );
  }

  Widget _buildReceiptCard(BuildContext context, AppState state) {
    final double subtotal = state.cartSubtotal;
    
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
          Text('Receipt Details', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          _buildReceiptRow('Items Subtotal (Virtual)', '₹${subtotal.toInt()}'),
          _buildReceiptRow('Imaginary Discount (100%)', '-₹${subtotal.toInt()}', isGreen: true),
          _buildReceiptRow('Calorie Delivery Fee', '₹0'),
          const Divider(color: AppTheme.darkBorder, height: 24),
          _buildReceiptRow('Order Total', '₹0', isBold: true),
          const SizedBox(height: 4),
          _buildReceiptRow('Real Money Saved', '₹${subtotal.toInt()}', isBold: true, isGreen: true),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryAccent,
                shape: RoundedRectangleBorder(borderRadius: AppTheme.borderMedium),
              ),
              onPressed: () {
                showDialog<bool>(
                  context: context,
                  builder: (context) => PaymentDialog(subtotal: subtotal),
                ).then((confirmed) {
                  if (confirmed == true) {
                    showGeneralDialog(
                      context: context,
                      barrierDismissible: false,
                      barrierLabel: 'SuccessDialog',
                      pageBuilder: (context, anim1, anim2) => const OrderSuccessOverlay(),
                    ).then((_) {
                      state.placeSimulatedOrder();
                      state.setTab(2);
                    });
                  }
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Proceed to Payment',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isGreen = false, bool isBold = false}) {
    final TextStyle style = GoogleFonts.inter(
      fontSize: 14,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      color: isGreen 
          ? AppTheme.successGreen 
          : (isBold ? AppTheme.textPrimary : AppTheme.textSecondary),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
