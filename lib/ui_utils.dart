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
      [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)], // Midnight Blue
      [const Color(0xFF121212), const Color(0xFF282828)],   // Sleek Dark
      [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)],   // Electric Purple
      [const Color(0xFF00c6ff), const Color(0xFF0072ff)],   // Ocean Blue
      [const Color(0xFFf953c6), const Color(0xFFb91d73)],   // Pinkish
      [const Color(0xFF11998E), const Color(0xFF38EF7D)],   // Green-Cyan
      [const Color(0xFFF2994A), const Color(0xFFF2C94C)],   // Orange-Gold
    ];
  }

  static Widget buildImmersiveBackground(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF4FBF4),
            Color(0xFFE8F5E9),
            Color(0xFFFFFFFF),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: greenPrimary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: greenMid.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
