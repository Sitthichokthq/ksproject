import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'neptune_theme.dart' as neptune_theme;

// Neptune MIUI Theme Colors
class NeptuneColors {
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFF8A65);
  static const Color secondary = Color(0xFF4CAF50);
  static const Color accent = Color(0xFF9C27B0);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
}

// Neptune MIUI Theme
class NeptuneTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: NeptuneColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: NeptuneColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: NeptuneColors.surface,
        foregroundColor: NeptuneColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          color: NeptuneColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 20,
          letterSpacing: 0.2,
        ),
        iconTheme: const IconThemeData(color: NeptuneColors.primary),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: NeptuneColors.surface,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: NeptuneColors.surface,
        elevation: 8,
        selectedItemColor: NeptuneColors.primary,
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 12),
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: NeptuneColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        elevation: 4,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: NeptuneColors.primary.withOpacity(0.1),
        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: NeptuneColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18, color: NeptuneColors.textPrimary),
        contentTextStyle: GoogleFonts.inter(fontSize: 16, color: Colors.black87),
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme().apply(
          bodyColor: NeptuneColors.textPrimary,
          displayColor: NeptuneColors.textPrimary,
        ),
      ).copyWith(
        headlineMedium: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 24, color: NeptuneColors.textPrimary),
        titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 20, color: NeptuneColors.textPrimary),
        titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16, color: NeptuneColors.primary),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: NeptuneColors.textPrimary),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
        bodySmall: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
      ),
      useMaterial3: true,
    );
  }
}

// Neptune MIUI Card Widget
class NeptuneCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const NeptuneCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.backgroundColor,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation ?? 4,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(28),
      ),
      color: backgroundColor ?? NeptuneColors.surface,
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: onTap != null
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: borderRadius ?? BorderRadius.circular(28),
                onTap: onTap,
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(24),
                  child: child,
                ),
              ),
            )
          : Padding(
              padding: padding ?? const EdgeInsets.all(24),
              child: child,
            ),
    );
  }
}

// Neptune MIUI Gradient Header (Alipay style)
class NeptuneGradientHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final List<Color>? gradientColors;
  final Widget? trailing;

  const NeptuneGradientHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.gradientColors,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors ?? [
            NeptuneColors.primary,
            NeptuneColors.primaryLight,
            NeptuneColors.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: NeptuneColors.primary.withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: Colors.white, size: 36),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// Neptune MIUI Section Header (Alipay style)
class NeptuneSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? color;

  const NeptuneSectionHeader({
    super.key,
    required this.title,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 20, bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (color ?? NeptuneColors.primary).withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color ?? NeptuneColors.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: NeptuneColors.primary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// Neptune MIUI Value Card (Alipay style)
class NeptuneValueCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final double? value;
  final Color color;
  final String unit;
  final VoidCallback onTap;
  final bool? isNormal;

  const NeptuneValueCard({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.color,
    required this.unit,
    required this.onTap,
    this.isNormal,
  });

  @override
  Widget build(BuildContext context) {
    return NeptuneCard(
      borderRadius: BorderRadius.circular(28),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: color.withOpacity(0.13),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: neptune_theme.NeptuneColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      value != null ? value!.toStringAsFixed(2) : '-',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: neptune_theme.NeptuneColors.primaryDark,
                      ),
                    ),
                    if (unit.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        unit,
                        style: TextStyle(
                          fontSize: 18,
                          color: neptune_theme.NeptuneColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
                if (isNormal != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        isNormal! ? Icons.check_circle : Icons.warning,
                        size: 20,
                        color: isNormal! ? NeptuneColors.success : NeptuneColors.warning,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isNormal! ? 'ปกติ' : 'ผิดปกติ',
                        style: TextStyle(
                          fontSize: 14,
                          color: neptune_theme.NeptuneColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.13),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.chevron_right,
              color: NeptuneColors.primary,
              size: 28,
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

// Neptune MIUI Navigation Bar (Alipay style)
class NeptuneNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final List<NavigationDestination> destinations;

  const NeptuneNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 18),
      child: PhysicalModel(
        color: Colors.transparent,
        elevation: 16,
        borderRadius: BorderRadius.circular(32),
        shadowColor: NeptuneColors.primary.withOpacity(0.10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: NeptuneColors.primary.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: NavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              height: 72,
              indicatorColor: NeptuneColors.primary.withOpacity(0.10),
              selectedIndex: selectedIndex,
              animationDuration: const Duration(milliseconds: 350),
              destinations: destinations,
              onDestinationSelected: onDestinationSelected,
            ),
          ),
        ),
      ),
    );
  }
}

// Quick Action Button (Alipay style)
class AlipayQuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const AlipayQuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  (color ?? NeptuneColors.primaryLight),
                  (color ?? NeptuneColors.primary),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: (color ?? NeptuneColors.primary).withOpacity(0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: neptune_theme.NeptuneColors.primaryDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// Neptune MIUI Status Indicator
class NeptuneStatusIndicator extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;

  const NeptuneStatusIndicator({
    super.key,
    required this.text,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 