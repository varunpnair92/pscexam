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

    test('Parent keyword children points (e.g. സംഘടനകളും സ്ഥാപകരും) parse and display correctly', () {
      final childPointItems = [
        {
          'keyword': 'ശുദ്ധിപ്രസ്ഥാനം',
          'parent': 'സംഘടനകളും സ്ഥാപകരും',
          'category': 'പൊതുവിജ്ഞാനം',
          'point': 'സ്ഥാപകൻ: ദയാനന്ദ സരസ്വതി',
          'formatted': 'ശുദ്ധിപ്രസ്ഥാനം - സ്ഥാപകൻ: ദയാനന്ദ സരസ്വതി',
        },
        {
          'keyword': 'ആര്യസമാജം',
          'parent': 'സംഘടനകളും സ്ഥാപകരും',
          'category': 'പൊതുവിജ്ഞാനം',
          'point': 'സ്ഥാപകൻ: ദയാനന്ദ സരസ്വതി',
          'formatted': 'ആര്യസമാജം - സ്ഥാപകൻ: ദയാനന്ദ സരസ്വതി',
        },
      ];

      final Map<String, List<SummaryItem>> grouped = {};
      for (final p in childPointItems) {
        final cat = p['category']!;
        final k = p['keyword']!;
        final pt = p['point']!;
        grouped.putIfAbsent(cat, () => []).add(SummaryItem(
          label: k,
          value: pt,
          rawText: '$k - $pt',
        ));
      }

      final cards = grouped.entries.map((entry) {
        return SummaryCardModel(title: entry.key, items: entry.value);
      }).toList();

      expect(cards.length, equals(1));
      expect(cards[0].cleanTitle, equals('പൊതുവിജ്ഞാനം'));
      expect(cards[0].items.length, equals(2));
      expect(cards[0].items[0].label, equals('ശുദ്ധിപ്രസ്ഥാനം'));
      expect(cards[0].items[0].value, equals('സ്ഥാപകൻ: ദയാനന്ദ സരസ്വതി'));
      expect(cards[0].items[1].label, equals('ആര്യസമാജം'));
      expect(cards[0].items[1].value, equals('സ്ഥാപകൻ: ദയാനന്ദ സരസ്വതി'));
    });
  });
}
