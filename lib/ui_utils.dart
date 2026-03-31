import 'package:flutter/material.dart';

class UIUtils {
  static const Color greenPrimary = Color(0xFF1B8A4E);
  static const Color greenMid = Color(0xFF27AE60);
  static const Color greenLight = Color(0xFF52C97A);
  static const Color bgColor = Color(0xFFF4FBF4);
  static const Color textDark = Color(0xFF0D3320);
  static const Color textMid = Color(0xFF4D7A5E);
  static const Color gold = Color(0xFFF5A623);

  static IconData getIconForName(String name) {
    name = name.toLowerCase();
    if (name.contains('cricket') || name.contains('ക്രിക്കറ്റ്')) return Icons.sports_cricket_rounded;
    if (name.contains('football')) return Icons.sports_soccer_rounded;
    if (name.contains('exam') || name.contains('test')) return Icons.assignment_rounded;
    if (name.contains('ldc') || name.contains('clerk')) return Icons.badge_rounded;
    if (name.contains('level') || name.contains('degree')) return Icons.workspace_premium_rounded;
    if (name.contains('math') || name.contains('അങ്കഗണിതം')) return Icons.calculate_rounded;
    if (name.contains('science') || name.contains('ശാസ്ത്രം')) return Icons.science_rounded;
    if (name.contains('history') || name.contains('ചриത്രം')) return Icons.history_edu_rounded;
    if (name.contains('english')) return Icons.language_rounded;
    if (name.contains('malayalam')) return Icons.menu_book_rounded;
    if (name.contains('gk') || name.contains('general')) return Icons.public_rounded;
    if (name.contains('it') || name.contains('cyber')) return Icons.computer_rounded;
    if (name.contains('special') || name.contains('topic')) return Icons.stars_rounded;
    if (name.contains('rocket') || name.contains('launch')) return Icons.rocket_launch_rounded;
    if (name.contains('constitution')) return Icons.gavel_rounded;
    if (name.contains('economy')) return Icons.trending_up_rounded;
    if (name.contains('literature')) return Icons.auto_stories_rounded;
    
    return Icons.folder_rounded; // Default
  }

  static List<List<Color>> getPremiumGradients() {
    return [
      [const Color(0xFF1B8A4E), const Color(0xFF27AE60)],   // deep→mid green
      [const Color(0xFF27AE60), const Color(0xFF52C97A)],   // mid→light green
      [const Color(0xFF6A11CB), const Color(0xFF2575FC)],   // Blue-Purple
      [const Color(0xFFFF5F6D), const Color(0xFFFFC371)],   // Red-Orange
      [const Color(0xFF11998E), const Color(0xFF38EF7D)],   // Green-Cyan
      [const Color(0xFFF2994A), const Color(0xFFF2C94C)],   // Orange-Gold
    ];
  }
}
