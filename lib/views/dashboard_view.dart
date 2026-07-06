import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_state.dart';
import '../theme/design_tokens.dart';
import 'order_history_dialog.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 900;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Savings Hub & Analytics', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(
            'Visualize the real-world impact of your virtual cravings simulator.',
            style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          
          // Stats Row
          _buildStatsRow(context, state, isMobile),
          const SizedBox(height: 24),
          
          if (isMobile)
            Column(
              children: [
                _buildLevelCard(state),
                const SizedBox(height: 24),
                _buildMilestonesCard(state),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildLevelCard(state)),
                const SizedBox(width: 24),
                Expanded(child: _buildMilestonesCard(state)),
              ],
            ),
          const SizedBox(height: 24),
          _buildSupportDopamineCard(isMobile),
        ],
      ),
    );
  }

  // --- Stats grid ---
  Widget _buildStatsRow(BuildContext context, AppState state, bool isMobile) {
    final List<Widget> stats = [
      _buildStatCard(
        '₹${state.moneySaved.toInt()}',
        'Real Money Saved',
        Icons.account_balance_wallet,
        AppTheme.successGreen,
      ),
      _buildStatCard(
        '${state.caloriesSaved} kcal',
        'Calories Dodged',
        Icons.whatshot,
        AppTheme.primaryAccent,
      ),
      _buildStatCard(
        '${state.ordersPlaced}',
        'Ghost Orders Placed',
        Icons.check_circle,
        const Color(0xFF2196F3),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => const OrderHistoryDialog(),
          );
        },
      ),
    ];

    if (isMobile) {
      return Column(
        children: stats.map((card) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: card,
        )).toList(),
      );
    } else {
      return Row(
        children: stats.map((card) => Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: card,
          ),
        )).toList(),
      );
    }
  }

  Widget _buildStatCard(String value, String title, IconData icon, Color color, {VoidCallback? onTap}) {
    final cardContent = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        border: Border.all(color: AppTheme.darkBorder),
        borderRadius: AppTheme.borderMedium,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            radius: 24,
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }

  // --- XP Level Progress card ---
  Widget _buildLevelCard(AppState state) {
    final int nextLvlXP = state.currentLevel * 100;
    final double xpProgress = (state.xp / nextLvlXP).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        border: Border.all(color: AppTheme.darkBorder),
        borderRadius: AppTheme.borderMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Crave Level Status', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkSurfaceElevated,
              borderRadius: AppTheme.borderMedium,
            ),
            child: Row(
              children: [
                const Icon(Icons.workspace_premium, color: AppTheme.warningGold, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(state.levelTitle, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Level ${state.currentLevel}', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Experience to next level', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary)),
              Text('${state.xp} / $nextLvlXP XP', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: xpProgress,
              backgroundColor: AppTheme.darkSurfaceElevated,
              color: AppTheme.primaryAccent,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '*Earn XP by browsing categories, adding items to plates, and completing virtual delivery timings.',
            style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
          )
        ],
      ),
    );
  }

  // --- Savings Goal Milestones ---
  Widget _buildMilestonesCard(AppState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        border: Border.all(color: AppTheme.darkBorder),
        borderRadius: AppTheme.borderMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What can you buy with your real savings?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.milestones.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final m = state.milestones[idx];
              final bool isUnlocked = state.moneySaved >= m.price;
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurfaceElevated,
                  border: Border.all(
                    color: isUnlocked ? AppTheme.successGreen : AppTheme.darkBorder,
                  ),
                  borderRadius: AppTheme.borderMedium,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${m.name} ${isUnlocked ? "🔓" : "🔒"}',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: isUnlocked ? AppTheme.successGreen : AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            m.description,
                            style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMuted),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isUnlocked 
                            ? AppTheme.successGreen.withOpacity(0.15) 
                            : AppTheme.darkSurface,
                        borderRadius: AppTheme.borderSmall,
                      ),
                      child: Text(
                        '₹${m.price.toInt()}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: isUnlocked ? AppTheme.successGreen : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportDopamineCard(bool isMobile) {
    final content = [
      CircleAvatar(
        backgroundColor: const Color(0xFFFFDD00).withOpacity(0.15),
        radius: 26,
        child: const Icon(Icons.coffee, color: Color(0xFFFFDD00), size: 28),
      ),
      if (!isMobile) const SizedBox(width: 16) else const SizedBox(height: 12),
      Expanded(
        flex: isMobile ? 0 : 1,
        child: Column(
          crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Text(
              'Support Grubzy Development',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: isMobile ? TextAlign.center : TextAlign.start,
            ),
            const SizedBox(height: 4),
            Text(
              'Enjoying your zero-calorie cravings? Support our maintenance with a hot virtual cup of coffee.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
              textAlign: isMobile ? TextAlign.center : TextAlign.start,
            ),
          ],
        ),
      ),
      if (!isMobile) const SizedBox(width: 16) else const SizedBox(height: 16),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFDD00),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: AppTheme.borderMedium),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        onPressed: () async {
          final Uri url = Uri.parse('https://razorpay.me/@grubzy');
          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
            debugPrint('Could not launch support URL');
          }
        },
        child: Text(
          'Buy Coffee',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E12),
        border: Border.all(color: const Color(0xFFFFDD00).withOpacity(0.3)),
        borderRadius: AppTheme.borderMedium,
      ),
      child: isMobile
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: content,
            )
          : Row(
              children: content,
            ),
    );
  }
}
