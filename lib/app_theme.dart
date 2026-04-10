import 'package:flutter/material.dart';
import 'ui_utils.dart';

class AppTheme {
  // ─── COLORS ───
  static const Color primary = Color(0xFF1B8A4E);
  static const Color secondary = Color(0xFF27AE60);
  static const Color accent = Color(0xFF52C97A);
  static const Color background = Color(0xFFF4FBF4);
  static const Color textDark = Color(0xFF0A2318); // Slightly deeper, more premium green-dark
  static const Color textMid = Color(0xFF4D7A5E);
  static const Color textLight = Colors.white;

  // ─── GRADIENTS ───
  static List<List<Color>> get premiumGradients => UIUtils.getPremiumGradients();

  // ─── TYPOGRAPHY ───
  static const TextStyle titleStyle = TextStyle(
    color: textDark,
    fontWeight: FontWeight.bold,
    fontSize: 18,
    letterSpacing: 0.5,
  );

  static const TextStyle subtitleStyle = TextStyle(
    color: textMid,
    fontWeight: FontWeight.w600,
    fontSize: 14,
  );

  static const TextStyle cardTitleStyle = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  static const TextStyle breadcrumbStyle = TextStyle(
    color: textMid,
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );

  // ─── COMPONENTS ───
  
  static Widget buildImmersiveBackground(BuildContext context) {
    return UIUtils.buildImmersiveBackground(context);
  }

  static Widget buildPremiumAppBar({
    required String title,
    VoidCallback? onBack,
    List<Widget>? actions,
  }) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            if (onBack != null)
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textDark, size: 20),
                onPressed: onBack,
              )
            else
              const SizedBox(width: 48),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: titleStyle,
              ),
            ),
            if (actions != null) ...actions else const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  static Widget buildPremiumSearchBar({
    required ValueChanged<String> onChanged,
    required String hintText,
    required TextEditingController controller,
    VoidCallback? onClear,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            prefixIcon: const Icon(Icons.search_rounded, color: primary, size: 20),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 18),
                    onPressed: onClear,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 13),
          ),
        ),
      ),
    );
  }

  static Widget buildStaggeredAnimation({
    required int index,
    required Widget child,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index % 10) * 100),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, val, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - val)),
          child: Opacity(opacity: val, child: child),
        );
      },
      child: child,
    );
  }

  static BoxDecoration glassBox({
    required List<Color> gradient,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: gradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: gradient.first.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  static Widget buildLockedOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ColorFilter.mode(
            Colors.black.withOpacity(0.08),
            BlendMode.darken,
          ),
          child: const Center(
            child: Icon(Icons.lock_rounded, color: Colors.white70, size: 28),
          ),
        ),
      ),
    );
  }

  // ─── FULL THEMES ───
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        primaryColor: primary,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: primary,
        scaffoldBackgroundColor: const Color(0xFF08120C), // More midnight green than pure black
        colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.dark),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      );
}
