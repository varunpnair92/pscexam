import 'package:flutter/material.dart';

class FeatureDemoModel {
  final int id;
  final String name;
  final String navigation;
  final String url;
  final String orientation;
  final List<String> keywords;
  final String accessType;
  final bool isDemo;
  final int demoOrder;
  final String demoDescription;

  FeatureDemoModel({
    required this.id,
    required this.name,
    required this.navigation,
    required this.url,
    required this.orientation,
    required this.keywords,
    required this.accessType,
    required this.isDemo,
    required this.demoOrder,
    required this.demoDescription,
  });

  factory FeatureDemoModel.fromJson(Map<String, dynamic> json) {
    var rawKeywords = json['keywords'];
    List<String> parsedKeywords = [];
    if (rawKeywords is List) {
      parsedKeywords = rawKeywords.map((e) => e.toString()).toList();
    }

    return FeatureDemoModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      navigation: json['navigation']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      orientation: json['orientation']?.toString() ?? 'horizontal',
      keywords: parsedKeywords,
      accessType: json['access_type']?.toString() ?? 'free',
      isDemo: json['is_demo'] == true || json['is_demo'] == 'true' || json['is_demo'] == 1,
      demoOrder: json['demo_order'] is int
          ? json['demo_order']
          : int.tryParse(json['demo_order']?.toString() ?? '0') ?? 0,
      demoDescription: json['demo_description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toNodeMap() {
    return {
      "id": id,
      "name": name,
      "navigation": navigation,
      "url": url,
      "orientation": orientation,
      "keywords": keywords,
      "access_type": accessType,
    };
  }

  IconData get iconData {
    final nav = navigation.toLowerCase();
    final u = url.toLowerCase();
    final n = name.toLowerCase();

    if (nav.contains('summary') ||
        u.contains('summary') ||
        n.contains('summary') ||
        n.contains('സംഗ്രഹം') ||
        n.contains('കുറിപ്പ്')) {
      return Icons.menu_book_rounded;
    }
    if (nav.contains('battle') || n.contains('battle') || n.contains('ബാറ്റിൽ')) {
      return Icons.military_tech_rounded;
    }
    if (nav.contains('timeline') ||
        u.contains('timeline') ||
        n.contains('timeline') ||
        n.contains('ടൈംലൈൻ')) {
      return Icons.timeline_rounded;
    }
    if (nav.contains('search') || n.contains('search') || n.contains('തിരയുക')) {
      return Icons.search_rounded;
    }
    if (nav.contains('exam') || u.contains('exam') || n.contains('പരീക്ഷ')) {
      return Icons.quiz_rounded;
    }
    return Icons.auto_awesome_rounded;
  }

  List<Color> get gradientColors {
    final nav = navigation.toLowerCase();
    final u = url.toLowerCase();
    final n = name.toLowerCase();

    if (nav.contains('summary') ||
        u.contains('summary') ||
        n.contains('summary') ||
        n.contains('സംഗ്രഹം')) {
      return [const Color(0xFF1B8A4E), const Color(0xFF27AE60)];
    }
    if (nav.contains('battle') || n.contains('battle')) {
      return [const Color(0xFFE65100), const Color(0xFFFF9800)];
    }
    if (nav.contains('timeline') || u.contains('timeline') || n.contains('timeline')) {
      return [const Color(0xFF3F51B5), const Color(0xFF2196F3)];
    }
    if (nav.contains('search') || n.contains('search')) {
      return [const Color(0xFF0D47A1), const Color(0xFF1976D2)];
    }
    if (nav.contains('exam') || n.contains('exam')) {
      return [const Color(0xFF6A1B9A), const Color(0xFF8E24AA)];
    }
    return [const Color(0xFF1B8A4E), const Color(0xFF00796B)];
  }

  String get fallbackDescription {
    if (demoDescription.trim().isNotEmpty) {
      return demoDescription.trim();
    }
    final nav = navigation.toLowerCase();
    final u = url.toLowerCase();
    final n = name.toLowerCase();

    if (nav.contains('summary') ||
        u.contains('summary') ||
        n.contains('summary') ||
        n.contains('സംഗ്രഹം')) {
      return "പ്രധാന വിഷയങ്ങളുടെ സമഗ്രമായ സംഗ്രഹങ്ങളും ക്വിക്ക് ഫാക്ടുകളും ഒരിടത്ത് വായിച്ചു മനസ്സിലാക്കാം.";
    }
    if (nav.contains('battle') || n.contains('battle')) {
      return "മറ്റു ഉദ്യോഗാർത്ഥികളുമായി തത്സമയം മത്സരിച്ച് നിങ്ങളുടെ ലൈവ് റാങ്കും സ്കോറും പരിശോധിക്കാം.";
    }
    if (nav.contains('timeline') || u.contains('timeline') || n.contains('timeline')) {
      return "ചരിത്ര സംഭവങ്ങളെ കാലക്രമത്തിൽ ഇൻഫോഗ്രാഫിക് ടൈംലൈനിലൂടെ എളുപ്പത്തിൽ പഠിക്കാം.";
    }
    if (nav.contains('search') || n.contains('search')) {
      return "ഏതൊരു പി.എസ്.സി വിഷയവും മലയാളത്തിലും ഇംഗ്ലീഷിലും വേഗത്തിൽ തിരഞ്ഞു കണ്ടെത്താം.";
    }
    if (nav.contains('examcreate') || n.contains('create')) {
      return "നിങ്ങൾക്കിഷ്ടമുള്ള വിഷയങ്ങളിൽ നിമിഷങ്ങൾക്കകം മോക്ക് എക്സാമുകൾ സ്വയം നിർമ്മിച്ച് പരിശീലിക്കാം.";
    }
    return "പി.എസ്.സി പരീക്ഷകൾക്കായുള്ള ഏറ്റവും മികച്ച പരിശീലന ഫീച്ചറുകൾ ഇപ്പോൾ തന്നെ പരീക്ഷിച്ചു നോക്കൂ.";
  }
}
