import 'package:flutter_test/flutter_test.dart';
import 'package:psc_exam/summary_card_model.dart';

void main() {
  group('Summary Point by Point Parsing', () {
    test('Parses card models with keyword and point items', () {
      const raw = '''
# പ്രധാന നദികൾ #
പെരിയാർ - കേരളത്തിലെ ഏറ്റവും നീളം കൂടിയ നദി
ഭാരതപ്പുഴ - രണ്ടാമത്തെ വലിയ നദി
പമ്പ - മൂന്നാമത്തെ വലിയ നദി

# കായലുകൾ #
വേമ്പനാട് കായൽ - ഏറ്റവും വലിയ കായൽ
അഷ്ടമുടി കായൽ - രണ്ടാമത്തെ വലിയ കായൽ
''';

      final cards = SummaryCardModel.parse(raw);
      expect(cards.length, equals(2));
      expect(cards[0].cleanTitle, equals('പ്രധാന നദികൾ'));
      expect(cards[0].items.length, equals(3));
      expect(cards[0].items[0].label, equals('പെരിയാർ'));
      expect(cards[0].items[0].value, equals('കേരളത്തിലെ ഏറ്റവും നീളം കൂടിയ നദി'));
      expect(cards[0].items[0].hasValue, isTrue);

      expect(cards[1].cleanTitle, equals('കായലുകൾ'));
      expect(cards[1].items.length, equals(2));
      expect(cards[1].items[0].label, equals('വേമ്പനാട് കായൽ'));
      expect(cards[1].items[0].value, equals('ഏറ്റവും വലിയ കായൽ'));
    });

    test('Collects only keyword and point pairs across cards', () {
      const raw = '''
# ഉപവിഭാഗങ്ങൾ #
ജവാഹർലാൽ നെഹ്റു - ആദ്യ പ്രധാനമന്ത്രി
ലാൽ ബഹാദൂർ ശാസ്ത്രി - ജയ് ജവാൻ ജയ് കിസാൻ
''';

      final cards = SummaryCardModel.parse(raw);
      final pointsOnly = cards.expand((c) => c.items).where((i) => i.hasValue).toList();

      expect(pointsOnly.length, equals(2));
      expect(pointsOnly[0].label, equals('ജവാഹർലാൽ നെഹ്റു'));
      expect(pointsOnly[0].value, equals('ആദ്യ പ്രധാനമന്ത്രി'));
      expect(pointsOnly[1].label, equals('ലാൽ ബഹാദൂർ ശാസ്ത്രി'));
      expect(pointsOnly[1].value, equals('ജയ് ജവാൻ ജയ് കിസാൻ'));
    });
  });
}
