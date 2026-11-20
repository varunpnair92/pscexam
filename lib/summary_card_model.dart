import 'package:flutter/material.dart';

class SummaryItem {
  final String label;
  final String? value;
  final String rawText;

  SummaryItem({
    required this.label,
    this.value,
    required this.rawText,
  });

  bool get hasValue => value != null && value!.trim().isNotEmpty;
}

class SummaryCardModel {
  final String title;
  final List<SummaryItem> items;
  final String rawBlock;

  SummaryCardModel({
    required this.title,
    required this.items,
    this.rawBlock = '',
  });

  int get count => items.length;

  /// Clean display title (strips any leading/trailing # or extra whitespace)
  String get cleanTitle {
    String t = title.trim();
    while (t.startsWith('#')) {
      t = t.substring(1).trim();
    }
    while (t.endsWith('#')) {
      t = t.substring(0, t.length - 1).trim();
    }
    return t.isNotEmpty ? t : "Summary";
  }

  /// Short category name (e.g. "പൊതുവിജ്ഞാനം" from "പൊതുവിജ്ഞാനം (General Knowledge) - ആദ്യം / അവസാനം")
  String get shortTitle {
    String t = cleanTitle;
    if (t.contains('(')) {
      t = t.substring(0, t.indexOf('(')).trim();
    } else if (t.contains('-')) {
      t = t.substring(0, t.indexOf('-')).trim();
    }
    return t.isNotEmpty ? t : cleanTitle;
  }

  /// Copies this card's points as formatted text
  String toShareText() {
    final buffer = StringBuffer();
    buffer.writeln("# $cleanTitle");
    for (final item in items) {
      if (item.hasValue) {
        buffer.writeln("• ${item.label} - ${item.value}");
      } else {
        buffer.writeln("• ${item.rawText}");
      }
    }
    return buffer.toString().trim();
  }

  /// Returns topic-specific Icon and Color accent for card header
  IconData get icon {
    final lower = cleanTitle.toLowerCase();
    if (lower.contains('പൊതുവിജ്ഞാനം') || lower.contains('general knowledge')) {
      return Icons.lightbulb_outline_rounded;
    } else if (lower.contains('ഭൂമിശാസ്ത്രം') || lower.contains('geography')) {
      return Icons.public_rounded;
    } else if (lower.contains('ചരിത്രം') || lower.contains('history')) {
      return Icons.history_edu_rounded;
    } else if (lower.contains('രാഷ്ട്രീയം') || lower.contains('politics')) {
      return Icons.account_balance_rounded;
    } else if (lower.contains('സാഹിത്യം') || lower.contains('literature')) {
      return Icons.menu_book_rounded;
    } else if (lower.contains('സിനിമ') || lower.contains('cinema')) {
      return Icons.movie_creation_outlined;
    } else if (lower.contains('കായികം') || lower.contains('sports')) {
      return Icons.sports_soccer_rounded;
    } else if (lower.contains('വിദ്യാഭ്യാസം') || lower.contains('education')) {
      return Icons.school_rounded;
    } else if (lower.contains('കൃഷി') || lower.contains('agriculture')) {
      return Icons.eco_rounded;
    } else if (lower.contains('വ്യവസായം') || lower.contains('industry')) {
      return Icons.precision_manufacturing_rounded;
    } else if (lower.contains('ചുരുക്കം') || lower.contains('summary') || lower.contains('quick')) {
      return Icons.summarize_rounded;
    }
    return Icons.auto_stories_rounded;
  }

  Color get accentColor {
    final lower = cleanTitle.toLowerCase();
    if (lower.contains('പൊതുവിജ്ഞാനം') || lower.contains('general knowledge')) {
      return const Color(0xFF1B8A4E); // Green
    } else if (lower.contains('ഭൂമിശാസ്ത്രം') || lower.contains('geography')) {
      return const Color(0xFF0284C7); // Sky / Blue
    } else if (lower.contains('ചരിത്രം') || lower.contains('history')) {
      return const Color(0xFFB45309); // Amber / Bronze
    } else if (lower.contains('രാഷ്ട്രീയം') || lower.contains('politics')) {
      return const Color(0xFF6366F1); // Indigo
    } else if (lower.contains('സാഹിത്യം') || lower.contains('literature')) {
      return const Color(0xFF8B5CF6); // Purple
    } else if (lower.contains('സിനിമ') || lower.contains('cinema')) {
      return const Color(0xFFE11D48); // Rose
    } else if (lower.contains('കായികം') || lower.contains('sports')) {
      return const Color(0xFFEA580C); // Orange
    } else if (lower.contains('വിദ്യാഭ്യാസം') || lower.contains('education')) {
      return const Color(0xFF0D9488); // Teal
    } else if (lower.contains('കൃഷി') || lower.contains('agriculture')) {
      return const Color(0xFF15803D); // Emerald
    } else if (lower.contains('വ്യവസായം') || lower.contains('industry')) {
      return const Color(0xFF475569); // Slate
    } else if (lower.contains('ചുരുക്കം') || lower.contains('summary') || lower.contains('quick')) {
      return const Color(0xFF0F766E); // Deep Teal
    }
    return const Color(0xFF1B8A4E);
  }

  /// Parses card models from raw summary text or summary_lines list
  static List<SummaryCardModel> parse(String? rawSummary, {List<dynamic>? rawLines}) {
    List<String> lines = [];
    if (rawSummary != null && rawSummary.trim().isNotEmpty) {
      lines = rawSummary.split('\n').map((l) => l.trim()).toList();
    } else if (rawLines != null && rawLines.isNotEmpty) {
      lines = rawLines.map((e) => e.toString().trim()).toList();
    }

    if (lines.isEmpty) return [];

    // Check if there are # category # markers or category lines
    final bool hasHashMarkers = lines.any((l) => l.startsWith('#') || l.endsWith('#'));

    if (hasHashMarkers) {
      final List<SummaryCardModel> cards = [];
      String currentTitle = "വിവരം (Info)";
      List<SummaryItem> currentItems = [];
      List<String> currentBlockLines = [];

      for (final line in lines) {
        if (line.isEmpty) continue;

        // Is this line a category header? e.g. # Category # or # Category
        if (line.startsWith('#') && (line.endsWith('#') || !line.contains(' - '))) {
          if (currentItems.isNotEmpty || (cards.isNotEmpty && currentBlockLines.isNotEmpty)) {
            cards.add(SummaryCardModel(
              title: currentTitle,
              items: List.from(currentItems),
              rawBlock: currentBlockLines.join('\n'),
            ));
            currentItems.clear();
            currentBlockLines.clear();
          }
          String clean = line.replaceAll('#', '').trim();
          currentTitle = clean.isNotEmpty ? clean : "വിവരം (Info)";
          currentBlockLines.add(line);
        } else {
          currentBlockLines.add(line);
          if (line.contains(' - ')) {
            final idx = line.indexOf(' - ');
            currentItems.add(SummaryItem(
              label: line.substring(0, idx).trim().replaceFirst(RegExp(r'^[•\-\*]\s*'), ''),
              value: line.substring(idx + 3).trim(),
              rawText: line,
            ));
          } else if (line.contains(' : ')) {
            final idx = line.indexOf(' : ');
            currentItems.add(SummaryItem(
              label: line.substring(0, idx).trim().replaceFirst(RegExp(r'^[•\-\*]\s*'), ''),
              value: line.substring(idx + 3).trim(),
              rawText: line,
            ));
          } else {
            currentItems.add(SummaryItem(
              label: line.replaceFirst(RegExp(r'^[•\-\*]\s*'), ''),
              value: null,
              rawText: line,
            ));
          }
        }
      }

      if (currentItems.isNotEmpty || currentBlockLines.isNotEmpty) {
        cards.add(SummaryCardModel(
          title: currentTitle,
          items: List.from(currentItems),
          rawBlock: currentBlockLines.join('\n'),
        ));
      }

      if (cards.isNotEmpty) return cards;
    }

    // Fallback if no # category markers: parse all lines as items in a single card
    final List<SummaryItem> items = [];
    for (final line in lines) {
      if (line.isEmpty) continue;
      if (line.contains(' - ')) {
        final idx = line.indexOf(' - ');
        items.add(SummaryItem(
          label: line.substring(0, idx).trim().replaceFirst(RegExp(r'^[•\-\*]\s*'), ''),
          value: line.substring(idx + 3).trim(),
          rawText: line,
        ));
      } else {
        items.add(SummaryItem(
          label: line.replaceFirst(RegExp(r'^[•\-\*]\s*'), ''),
          value: null,
          rawText: line,
        ));
      }
    }

    if (items.isNotEmpty) {
      return [SummaryCardModel(title: "വിവരം (Info)", items: items, rawBlock: lines.join('\n'))];
    }

    return [];
  }

  static void _addBlockFromLines(List<SummaryCardModel> cards, List<String> lines) {
    if (lines.isEmpty) return;
    final title = lines.first;
    final List<SummaryItem> items = [];

    for (int i = 1; i < lines.length; i++) {
      final line = lines[i];
      if (line.contains(' - ')) {
        final idx = line.indexOf(' - ');
        items.add(SummaryItem(
          label: line.substring(0, idx).trim(),
          value: line.substring(idx + 3).trim(),
          rawText: line,
        ));
      } else if (line.contains(' : ')) {
        final idx = line.indexOf(' : ');
        items.add(SummaryItem(
          label: line.substring(0, idx).trim(),
          value: line.substring(idx + 3).trim(),
          rawText: line,
        ));
      } else {
        items.add(SummaryItem(
          label: line,
          value: null,
          rawText: line,
        ));
      }
    }

    if (lines.length == 1 && lines.first.contains(' - ')) {
      final idx = lines.first.indexOf(' - ');
      items.add(SummaryItem(
        label: lines.first.substring(0, idx).trim(),
        value: lines.first.substring(idx + 3).trim(),
        rawText: lines.first,
      ));
      cards.add(SummaryCardModel(title: "വിവരം (Info)", items: items, rawBlock: lines.join('\n')));
    } else {
      cards.add(SummaryCardModel(title: title, items: items, rawBlock: lines.join('\n')));
    }
  }
}
