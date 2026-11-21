import 'package:flutter_test/flutter_test.dart';
import 'package:psc_exam/summary_card_model.dart';

void main() {
  group('Summary Card Model Parsing', () {
    test('Parses real database style # blocks with headings like ആദ്യം and കാലക്രമത്തിൽ', () {
      const realSummary = '''
#
ആദ്യം / അവസാനം

ആദ്യത്തെ മുഖ്യമന്ത്രി - ഇ.എം.എസ്. നമ്പൂതിരിപ്പാട് (1957)
ഏറ്റവും കൂടുതൽ കാലം മുഖ്യമന്ത്രി - സി. അച്യുതമേനോൻ (1970-77)
#

#
കാലക്രമത്തിൽ

ഇ.എം.എസ്. നമ്പൂതിരിപ്പാട് - 1957-1959
പട്ടം എ. താണുപിള്ള - 1960-1962
#
''';

      final cards = SummaryCardModel.parse(realSummary);
      expect(cards.length, equals(2));
      expect(cards[0].cleanTitle, equals('ആദ്യം / അവസാനം'));
      expect(cards[0].items.length, equals(2));
      expect(cards[0].items[0].label, equals('ആദ്യത്തെ മുഖ്യമന്ത്രി'));
      expect(cards[0].items[0].value, equals('ഇ.എം.എസ്. നമ്പൂതിരിപ്പാട് (1957)'));

      expect(cards[1].cleanTitle, equals('കാലക്രമത്തിൽ'));
      expect(cards[1].items.length, equals(2));
      expect(cards[1].items[0].label, equals('ഇ.എം.എസ്. നമ്പൂതിരിപ്പാട്'));
      expect(cards[1].items[0].value, equals('1957-1959'));
    });

    test('Extracts point-by-point keyword and point pairs across multiple categories', () {
      const realSummary = '''
#
ആദ്യം / അവസാനം
ആദ്യത്തെ മുഖ്യമന്ത്രി - ഇ.എം.എസ്. നമ്പൂതിരിപ്പാട് (1957)
ഏറ്റവും കൂടുതൽ കാലം മുഖ്യമന്ത്രി - സി. അച്യുതമേനോൻ (1970-77)
#

#
കാലക്രമത്തിൽ
ഇ.എം.എസ്. നമ്പൂതിരിപ്പാട് - 1957-1959
#
''';

      final cards = SummaryCardModel.parse(realSummary);
      final allPoints = <Map<String, String>>[];
      for (final card in cards) {
        for (final item in card.items) {
          if (item.hasValue) {
            allPoints.add({
              'keyword': item.label,
              'point': item.value!,
              'category': card.cleanTitle,
            });
          }
        }
      }

      expect(allPoints.length, equals(3));
      expect(allPoints[0]['keyword'], equals('ആദ്യത്തെ മുഖ്യമന്ത്രി'));
      expect(allPoints[0]['point'], equals('ഇ.എം.എസ്. നമ്പൂതിരിപ്പാട് (1957)'));
      expect(allPoints[0]['category'], equals('ആദ്യം / അവസാനം'));

      expect(allPoints[1]['keyword'], equals('ഏറ്റവും കൂടുതൽ കാലം മുഖ്യമന്ത്രി'));
      expect(allPoints[1]['point'], equals('സി. അച്യുതമേനോൻ (1970-77)'));

      expect(allPoints[2]['keyword'], equals('ഇ.എം.എസ്. നമ്പൂതിരിപ്പാട്'));
      expect(allPoints[2]['point'], equals('1957-1959'));
      expect(allPoints[2]['category'], equals('കാലക്രമത്തിൽ'));
    });
  });
}
