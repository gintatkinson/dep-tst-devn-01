import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/reference_frame.dart';
import 'package:app_flutter/domain/reference_frame_validation.dart';

void main() {
  group('validateReferenceFrame — BDD scenarios from feat-01', () {
    test('Scenario 1: default astronomical body is "earth"', () {
      const frame = ReferenceFrame();
      final result = validateReferenceFrame(frame, alternateSystemsFeatureEnabled: false);
      expect(result.isValid, isTrue);
      expect(result.normalizedFrame.astronomicalBody, 'earth');
    });

    test('Scenario 2: non-earth body "moon" stored correctly', () {
      const frame = ReferenceFrame(astronomicalBody: 'moon');
      final result = validateReferenceFrame(frame, alternateSystemsFeatureEnabled: false);
      expect(result.isValid, isTrue);
      expect(result.normalizedFrame.astronomicalBody, 'moon');
    });

    test('Scenario 3: alternate-system accepted when feature enabled', () {
      const frame = ReferenceFrame(astronomicalBody: 'earth', alternateSystem: 'sim-env-1');
      final result = validateReferenceFrame(frame, alternateSystemsFeatureEnabled: true);
      expect(result.isValid, isTrue);
      expect(result.normalizedFrame.alternateSystem, 'sim-env-1');
    });

    test('Scenario 4: alternate-system rejected when feature NOT enabled', () {
      const frame = ReferenceFrame(astronomicalBody: 'earth', alternateSystem: 'sim-env-1');
      final result = validateReferenceFrame(frame, alternateSystemsFeatureEnabled: false);
      expect(result.isValid, isFalse);
      expect(result.error, contains('feature-not-supported'));
    });

    test('Scenario 5: control characters in astronomical-body rejected', () {
      final frame = ReferenceFrame(astronomicalBody: 'earth\t');
      final result = validateReferenceFrame(frame, alternateSystemsFeatureEnabled: false);
      expect(result.isValid, isFalse);
      expect(result.error, contains('pattern'));
    });

    test('Scenario 6: uppercase astronomical-body normalized to lowercase', () {
      const frame = ReferenceFrame(astronomicalBody: 'Earth');
      final result = validateReferenceFrame(frame, alternateSystemsFeatureEnabled: false);
      expect(result.isValid, isTrue);
      expect(result.normalizedFrame.astronomicalBody, 'earth');
    });

    test('Scenario 7: leading "the " prefix stripped from astronomical-body', () {
      const frame = ReferenceFrame(astronomicalBody: 'the moon');
      final result = validateReferenceFrame(frame, alternateSystemsFeatureEnabled: false);
      expect(result.isValid, isTrue);
      expect(result.normalizedFrame.astronomicalBody, 'moon');
    });
  });
}
