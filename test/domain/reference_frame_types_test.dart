import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/reference_frame.dart';

import '../shared/body_fixtures.dart';

void main() {
  group('ReferenceFrame', () {
    test('defaults astronomical body to "earth"', () {
      const frame = ReferenceFrame();
      expect(frame.astronomicalBody, kTestBodyEarth);
      expect(frame.alternateSystem, isNull);
    });

    test('round-trip JSON serialization', () {
      const frame = ReferenceFrame(astronomicalBody: kTestBodyMoon, alternateSystem: null);
      final json = frame.toJson();
      final restored = ReferenceFrame.fromJson(json);
      expect(restored.astronomicalBody, kTestBodyMoon);
      expect(restored.alternateSystem, isNull);
    });

    test('round-trip JSON with alternate system', () {
      const frame = ReferenceFrame(astronomicalBody: kTestBodyMars, alternateSystem: 'sim-env-1');
      final json = frame.toJson();
      final restored = ReferenceFrame.fromJson(json);
      expect(restored.astronomicalBody, kTestBodyMars);
      expect(restored.alternateSystem, 'sim-env-1');
    });

    test('equality: same values are equal', () {
      const a = ReferenceFrame(astronomicalBody: kTestBodyEarth);
      const b = ReferenceFrame(astronomicalBody: kTestBodyEarth);
      expect(a, equals(b));
    });

    test('equality: different values are not equal', () {
      const a = ReferenceFrame(astronomicalBody: kTestBodyEarth);
      const b = ReferenceFrame(astronomicalBody: kTestBodyMoon);
      expect(a, isNot(equals(b)));
    });
  });
}
