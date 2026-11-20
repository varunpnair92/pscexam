import 'package:flutter_test/flutter_test.dart';
import 'package:psc_exam/feature_demo_model.dart';

void main() {
  group('FeatureDemoModel Navigation Analysis', () {
    test('parentNavigation node maps to isParentNav and authentic labels', () {
      final model = FeatureDemoModel.fromJson({
        'id': 101,
        'name': 'ഇന്ത്യൻ ഭരണഘടന',
        'navigation': 'parentNavigation',
        'keywords': ['ഭരണഘടന', 'ആമുഖം', 'മൗലികാവകാശങ്ങൾ'],
        'children': [
          {'name': 'ആമുഖം', 'keyword': 'ആമുഖം'},
          {'name': 'മൗലികാവകാശങ്ങൾ', 'keyword': 'മൗലികാവകാശങ്ങൾ'},
        ],
      });

      expect(model.isParentNav, isTrue);
      expect(model.isSearchParentNav, isFalse);
      expect(model.demoQuery, equals('ഭരണഘടന'));
      expect(model.actionButtonLabel, equals('വിഷയങ്ങൾ കാണുക'));
      expect(model.sampleSearchGridItems.length, greaterThanOrEqualTo(2));
      expect(model.sampleSearchGridItems[0]['name'], equals('ആമുഖം'));
    });

    test('searchParentNavigation node maps to isSearchParentNav', () {
      final model = FeatureDemoModel.fromJson({
        'id': 102,
        'name': 'കേരള നവോത്ഥാനം',
        'navigation': 'searchParentNavigation',
        'keywords': ['നവോത്ഥാനം', 'ഗുരു'],
      });

      expect(model.isSearchParentNav, isTrue);
      expect(model.demoQuery, equals('നവോത്ഥാനം'));
      expect(model.actionButtonLabel, equals('വിഷയം തിരയുക'));
    });

    test('navigationSlide node maps to isSlide', () {
      final model = FeatureDemoModel.fromJson({
        'id': 103,
        'name': 'പഠന സ്ലൈഡുകൾ',
        'navigation': 'navigationSlide',
      });

      expect(model.isSlide, isTrue);
      expect(model.actionButtonLabel, equals('സ്ലൈഡുകൾ കാണുക'));
    });

    test('timeline node maps to isTimeline', () {
      final model = FeatureDemoModel.fromJson({
        'id': 104,
        'name': 'സ്വാതന്ത്ര്യ സമരങ്ങൾ',
        'navigation': 'timeline',
        'keywords': ['സമരം'],
      });

      expect(model.isTimeline, isTrue);
      expect(model.actionButtonLabel, equals('ടൈംലൈൻ കാണുക'));
    });

    test('exambattle node maps to isBattle', () {
      final model = FeatureDemoModel.fromJson({
        'id': 105,
        'name': 'LDC Battle',
        'navigation': 'exambattle',
      });

      expect(model.isBattle, isTrue);
      expect(model.actionButtonLabel, equals('ബാറ്റിൽ തുടങ്ങുക'));
    });

    test('examcreate node maps to isExamCreate', () {
      final model = FeatureDemoModel.fromJson({
        'id': 106,
        'name': 'Create Exam',
        'navigation': 'examcreate',
        'keywords': ['കേരള ചരിത്രം'],
      });

      expect(model.isExamCreate, isTrue);
      expect(model.actionButtonLabel, equals('പരീക്ഷ നിർമ്മിക്കുക'));
    });

    test('knowledgeCapsule node maps to isKnowledgeCapsule', () {
      final model = FeatureDemoModel.fromJson({
        'id': 107,
        'name': 'റിവിഷൻ കാപ്സ്യൂൾ',
        'navigation': 'knowledgeCapsule',
      });

      expect(model.isKnowledgeCapsule, isTrue);
      expect(model.actionButtonLabel, equals('കാപ്സ്യൂൾ കാണുക'));
    });

    test('graphView node maps to isGraphView', () {
      final model = FeatureDemoModel.fromJson({
        'id': 108,
        'name': 'കോൺസെപ്റ്റ് ഗ്രാഫ്',
        'navigation': 'graphView',
      });

      expect(model.isGraphView, isTrue);
      expect(model.actionButtonLabel, equals('ഗ്രാഫ് കാണുക'));
    });

    test('studySearch node maps to isStudySearch', () {
      final model = FeatureDemoModel.fromJson({
        'id': 109,
        'name': 'സ്റ്റഡി സെർച്ച്',
        'navigation': 'studySearch',
      });

      expect(model.isStudySearch, isTrue);
      expect(model.actionButtonLabel, equals('ചോദ്യങ്ങൾ തിരയുക'));
    });

    test('studyFull node maps to isStudyQuiz', () {
      final model = FeatureDemoModel.fromJson({
        'id': 110,
        'name': 'മോക്ക് ടെസ്റ്റ്',
        'navigation': 'studyFull',
      });

      expect(model.isStudyQuiz, isTrue);
      expect(model.actionButtonLabel, equals('പരിശീലനം തുടങ്ങുക'));
    });

    test('examstorypage node maps to isExamStory', () {
      final model = FeatureDemoModel.fromJson({
        'id': 6,
        'name': 'liveexam',
        'navigation': 'examstorypage',
        'url': 'activeexams/live',
      });

      expect(model.isExamStory, isTrue);
      expect(model.actionButtonLabel, equals('സ്റ്റോറി കാണുക'));
      expect(model.categoryTitle, equals('Live Exams'));
    });

    test('activeexams url maps to isExamStory', () {
      final model = FeatureDemoModel.fromJson({
        'id': 111,
        'name': 'ലൈവ് പരീക്ഷകൾ',
        'navigation': '',
        'url': 'activeexams/live/',
      });

      expect(model.isExamStory, isTrue);
    });
  });
}
