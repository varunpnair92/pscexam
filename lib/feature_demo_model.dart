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
  final String? previewQuery;
  final List<String> previewPoints;
  final String? previewCategory;
  final List<String> previewStats;
  final bool isTimeline;
  final List<Map<String, dynamic>> timelineEvents;
  final bool isSummary;
  final bool isBattle;
  final bool isImportantSearch;
  final String? summaryDescription;
  final List<String> summaryCategories;
  final List<Map<String, String>> summaryCards;
  final List<Map<String, dynamic>> searchGrid;

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
    this.previewQuery,
    this.previewPoints = const [],
    this.previewCategory,
    this.previewStats = const [],
    this.isTimeline = false,
    this.timelineEvents = const [],
    this.isSummary = false,
    this.isBattle = false,
    this.isImportantSearch = false,
    this.summaryDescription,
    this.summaryCategories = const [],
    this.summaryCards = const [],
    this.searchGrid = const [],
  });

  factory FeatureDemoModel.fromJson(Map<String, dynamic> json) {
    var rawKeywords = json['keywords'];
    List<String> parsedKeywords = [];
    if (rawKeywords is List) {
      parsedKeywords = rawKeywords.map((e) => e.toString()).toList();
    }

    var rawPoints = json['preview_points'];
    List<String> parsedPoints = [];
    if (rawPoints is List) {
      parsedPoints = rawPoints.map((e) => e.toString()).toList();
    }

    var rawStats = json['preview_stats'];
    List<String> parsedStats = [];
    if (rawStats is List) {
      parsedStats = rawStats.map((e) => e.toString()).toList();
    }

    var rawEvents = json['timeline_events'];
    List<Map<String, dynamic>> parsedEvents = [];
    if (rawEvents is List) {
      for (var it in rawEvents) {
        if (it is Map) {
          parsedEvents.add(Map<String, dynamic>.from(it));
        }
      }
    }

    var rawSumCats = json['summary_categories'];
    List<String> parsedSumCats = [];
    if (rawSumCats is List) {
      parsedSumCats = rawSumCats.map((e) => e.toString()).toList();
    }

    var rawSumCards = json['summary_cards'];
    List<Map<String, String>> parsedSumCards = [];
    if (rawSumCards is List) {
      for (var it in rawSumCards) {
        if (it is Map) {
          parsedSumCards.add(it.map((k, v) => MapEntry(k.toString(), v.toString())));
        }
      }
    }

    var rawSearchGrid = json['search_grid'];
    List<Map<String, dynamic>> parsedSearchGrid = [];
    if (rawSearchGrid is List) {
      for (var it in rawSearchGrid) {
        if (it is Map) {
          parsedSearchGrid.add(Map<String, dynamic>.from(it));
        }
      }
    }

    final nav = (json['navigation']?.toString() ?? '').toLowerCase();
    final u = (json['url']?.toString() ?? '').toLowerCase();
    final n = (json['name']?.toString() ?? '').toLowerCase();
    final bool isTimelineFlag = json['is_timeline'] == true ||
        nav.contains('timeline') ||
        u.contains('timeline') ||
        n.contains('timeline') ||
        n.contains('ടൈംലൈൻ');
    final bool isSummaryFlag = json['is_summary'] == true ||
        nav.contains('summary') ||
        u.contains('summary') ||
        n.contains('summary') ||
        n.contains('സംഗ്രഹം');
    final bool isBattleFlag = json['is_battle'] == true ||
        nav.contains('battle') ||
        u.contains('battle') ||
        n.contains('battle') ||
        n.contains('ബാറ്റിൽ');
    final bool isSearchFlag = nav.contains('search') ||
        nav.contains('parentnavigation') ||
        n.contains('search') ||
        n.contains('തിരയുക') ||
        (!isTimelineFlag && !isSummaryFlag && !isBattleFlag);

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
      previewQuery: json['preview_query']?.toString(),
      previewPoints: parsedPoints,
      previewCategory: json['preview_category']?.toString(),
      previewStats: parsedStats,
      isTimeline: isTimelineFlag,
      timelineEvents: parsedEvents,
      isSummary: isSummaryFlag,
      isBattle: isBattleFlag,
      isImportantSearch: isSearchFlag,
      summaryDescription: json['summary_description']?.toString(),
      summaryCategories: parsedSumCats,
      summaryCards: parsedSumCards,
      searchGrid: parsedSearchGrid,
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

  String get demoQuery {
    if (isTimeline || navigation.toLowerCase().contains('timeline') || url.toLowerCase().contains('timeline') || name.toLowerCase().contains('timeline') || name.contains('ടൈംലൈൻ')) {
      if (previewQuery != null && previewQuery!.trim().isNotEmpty && !previewQuery!.toLowerCase().contains('timeline')) {
        return previewQuery!.trim();
      }
      return "കേരള സമരങ്ങൾ";
    }
    if (isSummary || navigation.toLowerCase().contains('summary') || url.toLowerCase().contains('summary') || name.toLowerCase().contains('summary') || name.contains('സംഗ്രഹം')) {
      if (previewQuery != null && previewQuery!.trim().isNotEmpty && !previewQuery!.toLowerCase().contains('summary')) {
        return previewQuery!.trim();
      }
      return "നദികൾ";
    }
    if (isBattle || navigation.toLowerCase().contains('battle') || name.toLowerCase().contains('battle') || name.contains('ബാറ്റിൽ')) {
      return "LDC മോക്ക് എക്സാം ബാറ്റിൽ";
    }
    if (previewQuery != null && previewQuery!.trim().isNotEmpty && !previewQuery!.toLowerCase().contains('node') && !previewQuery!.toLowerCase().contains('search')) {
      return previewQuery!.trim();
    }
    if (keywords.isNotEmpty && keywords.first.trim().isNotEmpty && keywords.first.toLowerCase() != 'node') {
      return keywords.first.trim();
    }
    final n = name.trim();
    if (n.isNotEmpty && n != 'Node' && n.toLowerCase() != 'search') return n;
    return "നദികൾ";
  }

  String get sampleSummaryDescription {
    if (summaryDescription != null && summaryDescription!.trim().isNotEmpty) {
      return summaryDescription!.trim();
    }
    if (demoQuery.contains('നദി')) {
      return "കേരളത്തിൽ ആകെ 44 നദികളുണ്ട്. അതിൽ 41 എണ്ണം പടിഞ്ഞാറോട്ടും 3 എണ്ണം കിഴക്കോട്ടും ഒഴുകുന്നു. ഏറ്റവും നീളം കൂടിയ നദി പെരിയാർ (244 കി.മീ) ആണ്.";
    }
    if (demoDescription.trim().isNotEmpty) {
      return demoDescription.trim();
    }
    return "പ്രധാന വിഷയങ്ങളുടെ സമഗ്രമായ സംഗ്രഹങ്ങളും വസ്തുതകളും ഇവിടെ പരിശോധിക്കാം.";
  }

  List<String> get sampleSummaryCategories {
    if (summaryCategories.isNotEmpty) return summaryCategories;
    if (demoQuery.contains('നദി')) {
      return ["All (5)", "പടിഞ്ഞാറോട്ട് ഒഴുകുന്നവ", "കിഴക്കോട്ട് ഒഴുകുന്നവ"];
    }
    return ["All", "പ്രധാന വസ്തുതകൾ", "ചരിത്രം"];
  }

  List<Map<String, String>> get sampleSummaryCards {
    if (summaryCards.isNotEmpty) return summaryCards;
    if (demoQuery.contains('നദി')) {
      return [
        {
          "title": "പെരിയാർ",
          "value": "244 കി.മീ",
          "desc": "കേരളത്തിന്റെ ജീവരേഖ, ഇടുക്കി അണക്കെട്ട്",
          "tag": "പടിഞ്ഞാറോട്ട്",
        },
        {
          "title": "ഭാരതപ്പുഴ",
          "value": "209 കി.മീ",
          "desc": "നിള നദി, മാമാങ്കം, മലമ്പുഴ അണക്കെട്ട്",
          "tag": "പടിഞ്ഞാറോട്ട്",
        },
        {
          "title": "പമ്പ",
          "value": "176 കി.മീ",
          "desc": "ദക്ഷിണ ഭാഗീരഥി, ശബരിമല, ആറന്മുള വള്ളംകളി",
          "tag": "പടിഞ്ഞാറോട്ട്",
        },
        {
          "title": "കബനി",
          "value": "57 കി.മീ",
          "desc": "കിഴക്കോട്ട് ഒഴുകുന്ന വലിയ നദി, ബാണാസുര സാഗർ",
          "tag": "കിഴക്കോട്ട്",
        },
      ];
    }
    return [
      {
        "title": "ആദ്യത്തെ മുഖ്യമന്ത്രി",
        "value": "ഇ.എം.എസ്. നമ്പൂതിരിപ്പാട്",
        "desc": "1957 ഏപ്രിൽ 5-ന് അധികാരമേറ്റു",
        "tag": "ചരിത്രം",
      },
      {
        "title": "കൂടുതൽ കാലം",
        "value": "സി. അച്യുതമേനോൻ",
        "desc": "1970 - 1977 കാലഘട്ടം (പൂർണ്ണ കാലാവധി)",
        "tag": "റെക്കോർഡ്",
      },
    ];
  }

  List<Map<String, dynamic>> get sampleSearchGridItems {
    if (searchGrid.isNotEmpty) {
      return searchGrid.map((it) {
        return {
          "name": it['name'] ?? '',
          "detail": it['detail'] ?? it['desc'] ?? '',
          "icon": Icons.topic_rounded,
          "gradient": [const Color(0xFF1565C0), const Color(0xFF1E88E5)],
        };
      }).toList();
    }
    if (demoQuery.contains('നദി')) {
      return [
        {
          "name": "പെരിയാർ",
          "detail": "244 കി.മീ • ജീവരേഖ",
          "icon": Icons.water_drop_rounded,
          "gradient": [const Color(0xFF1565C0), const Color(0xFF1E88E5)],
        },
        {
          "name": "ഭാരതപ്പുഴ",
          "detail": "209 കി.മീ • നിള നദി",
          "icon": Icons.waves_rounded,
          "gradient": [const Color(0xFF2E7D32), const Color(0xFF43A047)],
        },
        {
          "name": "പമ്പ",
          "detail": "176 കി.മീ • ശബരിമല",
          "icon": Icons.kayaking_rounded,
          "gradient": [const Color(0xFFE65100), const Color(0xFFFB8C00)],
        },
        {
          "name": "ചാലിയാർ",
          "detail": "169 കി.മീ • നിലമ്പൂർ",
          "icon": Icons.forest_rounded,
          "gradient": [const Color(0xFF6A1B9A), const Color(0xFF8E24AA)],
        },
      ];
    }
    return [
      {
        "name": "ശ്രീനാരായണഗുരു",
        "detail": "അരുവിപ്പുറം പ്രതിഷ്ഠ • 1888",
        "icon": Icons.menu_book_rounded,
        "gradient": [const Color(0xFF1565C0), const Color(0xFF1E88E5)],
      },
      {
        "name": "അയ്യങ്കാളി",
        "detail": "വില്ലുവണ്ടി സമരം • 1893",
        "icon": Icons.directions_bus_rounded,
        "gradient": [const Color(0xFF2E7D32), const Color(0xFF43A047)],
      },
      {
        "name": "ചട്ടമ്പിസ്വാമികൾ",
        "detail": "പ്രാചീന മലയാളം • പന്മന",
        "icon": Icons.school_rounded,
        "gradient": [const Color(0xFFE65100), const Color(0xFFFB8C00)],
      },
      {
        "name": "പൊയ്കയിൽ യോഹന്നാൻ",
        "detail": "PRDS സ്ഥാപകൻ • ഇരവിപേരൂർ",
        "icon": Icons.diversity_3_rounded,
        "gradient": [const Color(0xFF6A1B9A), const Color(0xFF8E24AA)],
      },
    ];
  }

  String get actionButtonLabel {
    final nav = navigation.toLowerCase();
    if (isTimeline || nav.contains('timeline') || url.toLowerCase().contains('timeline')) {
      return "ടൈംലൈൻ കാണുക";
    }
    if (nav.contains('battle')) return "ബാറ്റിൽ തുടങ്ങുക";
    if (nav.contains('summary')) return "സംഗ്രഹം";
    return "തിരയുക";
  }

  List<String> get sampleHighlightedPoints {
    // 1. If backend returned real preview points for this specific node
    if (previewPoints.isNotEmpty) {
      return previewPoints;
    }

    // 2. Timeline feature special handling for real Kerala Samarangal timeline events!
    final q = demoQuery;
    final nav = navigation.toLowerCase();
    if (isTimeline || nav.contains('timeline') || url.toLowerCase().contains('timeline') || q.contains('സമര')) {
      if (timelineEvents.isNotEmpty) {
        return timelineEvents.map((e) {
          final y = e['year'] ?? '';
          final t = e['title'] ?? '';
          final d = e['desc'] ?? '';
          return d.toString().isNotEmpty ? "$y — $t: $d" : "$y — $t";
        }).take(4).toList();
      }
      return [
        "1721 — ആറ്റിങ്ങൽ കലാപം: ബ്രിട്ടീഷുകാർക്കെതിരായ ആദ്യ സംഘടിത പ്രക്ഷോഭം",
        "1741 — കുളച്ചൽ യുദ്ധം: മാർത്താണ്ഡവർമ്മ ഡച്ച് സൈന്യത്തെ തോൽപ്പിച്ചു",
        "1809 — കുണ്ടറ വിളംബരം: വേലുത്തമ്പി ദളവയുടെ ചരിത്രപ്രസിദ്ധമായ ആഹ്വാനം",
        "1924 — വൈക്കം സത്യാഗ്രഹം: അയിത്തോച്ചാടന സമരം (ഗാന്ധിജിയുടെ സന്ദർശനം)",
      ];
    }

    // 3. If node has custom demo description entered in Node Manager
    if (demoDescription.trim().isNotEmpty) {
      final lines = demoDescription
          .split('\n')
          .map((e) => e.trim().replaceAll(RegExp(r'^[-•*0-9.]+\s*'), ''))
          .where((e) => e.length > 3)
          .toList();
      if (lines.length >= 2) return lines.take(3).toList();
      final sentences = demoDescription
          .split('.')
          .map((e) => e.trim())
          .where((e) => e.length > 8)
          .toList();
      if (sentences.length >= 2) return sentences.take(3).toList();
    }

    // 4. If node has multiple keywords attached, use those real keywords!
    if (keywords.length >= 2) {
      return keywords.take(3).map((kw) => "$kw — പ്രധാന സിലബസ് വിവരങ്ങളും ചോദ്യങ്ങളും").toList();
    }

    // 5. Tailor points to the specific query of THIS node
    if (q.contains('മുഖ്യമന്ത്രി')) {
      return [
        "ആദ്യത്തെ മുഖ്യമന്ത്രി — ഇ.എം.എസ്. നമ്പൂതിരിപ്പാട് (1957)",
        "ഏറ്റവും കൂടുതൽ കാലം മുഖ്യമന്ത്രി — സി. അച്യുതമേനോൻ (1970-77)",
        "ഏറ്റവും കുറഞ്ഞ കാലം — സി.എച്ച്. മുഹമ്മദ്കോയ (1979)",
      ];
    }
    if (q.contains('നവോത്ഥാനം') || q.contains('ഗുരു')) {
      return [
        "ശ്രീനാരായണഗുരു — അരുവിപ്പുറം പ്രതിഷ്ഠ (1888), SNDP രൂപീകരണം (1903)",
        "അയ്യങ്കാളി — വില്ലുവണ്ടി സമരം (1893), സാധുജന പരിപാലന സംഘം",
        "ചട്ടമ്പിസ്വാമികൾ — പ്രാചീന മലയാളം, വേദാധികാര നിരൂപണം",
      ];
    }
    if (q.contains('സ്വാതന്ത്ര്യ') || q.contains('ഗാന്ധി') || q.contains('കോൺഗ്രസ്')) {
      return [
        "1857 — ഒന്നാം സ്വാതന്ത്ര്യ സമരം (സിപായി ലഹള)",
        "1885 — ഇന്ത്യൻ നാഷണൽ കോൺഗ്രസ്സ് രൂപീകരണം (A.O. ഹ്യൂം)",
        "1947 — ഇന്ത്യ സ്വാതന്ത്ര്യം നേടി, ത്രിവർണ്ണ പതാക ഉയർന്നു",
      ];
    }
    if (q.contains('ഭരണഘടന') || q.contains('നിയമം')) {
      return [
        "ആമുഖം — ഇന്ത്യൻ ഭരണഘടനയുടെ താക്കോൽ (ജവഹർലാൽ നെഹ്റു)",
        "മൗലികാവകാശങ്ങൾ — ഭാഗം 3 (ആർട്ടിക്കിൾ 12-35)",
        "നിർദ്ദേശക തത്വങ്ങൾ — ഭാഗം 4 (അയർലണ്ടിൽ നിന്നും കടമെടുത്തു)",
      ];
    }
    if (navigation.toLowerCase().contains('battle') || q.contains('battle') || q.contains('Battle')) {
      return [
        "1,450+ ഉദ്യോഗാർത്ഥികളുമായി ലൈവ് റാങ്ക് മത്സരം",
        "ഓരോ ചോദ്യത്തിനും തൽക്ഷണ നെഗറ്റീവ് മാർക്ക് കണക്കാക്കൽ",
        "പരീക്ഷ പൂർത്തിയാകുമ്പോൾ തന്നെ ലൈവ് റാങ്ക് ലിസ്റ്റും സൊല്യൂഷനും",
      ];
    }

    // Node-specific facts using this node's actual name
    final nodeName = name.trim().isNotEmpty ? name.trim() : demoQuery;
    return [
      "$nodeName — സിലബസ് അടിസ്ഥാനമാക്കിയുള്ള സമഗ്ര വസ്തുതകൾ",
      "$nodeName — മുൻവർഷ ചോദ്യപേപ്പറുകളുടെ സമഗ്ര വിശകലനം",
      "$nodeName — പ്രധാന പരീക്ഷാ കുറിപ്പുകളും വസ്തുതകളും",
    ];
  }

  List<String> get sampleStats {
    if (previewStats.isNotEmpty) {
      return previewStats;
    }
    final q = demoQuery;
    final nav = navigation.toLowerCase();
    if (isTimeline || nav.contains('timeline') || q.contains('സമര')) {
      return ["# 1721-2007", "30 Events", "Chronological"];
    }
    final kwCount = keywords.isNotEmpty ? keywords.length : 1;
    if (nav.contains('battle')) {
      return ["# Live Rank", "100 Marks", "1,450+ Users"];
    }
    return ["# ID: #$id", "$kwCount Keywords", "PSC Syllabus"];
  }

  String get categoryTitle {
    if (previewCategory != null && previewCategory!.trim().isNotEmpty) {
      return previewCategory!.trim();
    }
    final q = demoQuery;
    final nav = navigation.toLowerCase();
    if (isTimeline || nav.contains('timeline') || q.contains('സമര')) {
      return "കേരള സമരങ്ങൾ • ചരിത്ര കാലക്രമം";
    }
    if (name.trim().isNotEmpty && name != 'Node') {
      return name.trim();
    }
    if (demoQuery.contains('മുഖ്യമന്ത്രി')) return "ആദ്യം / അവസാനം (10 Facts)";
    if (demoQuery.contains('നവോത്ഥാനം')) return "പ്രധാന സംഭവങ്ങളും വ്യക്തികളും";
    return "പ്രധാന സിലബസ് വിവരങ്ങൾ (Key Points)";
  }
}
