import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/reference_frame.dart';

void main() {
  group('ReferenceFrame', () {
    test('defaults astronomical body to "earth"', () {
      const frame = ReferenceFrame();
      expect(frame.astronomicalBody, 'earth');
      expect(frame.alternateSystem, isNull);
    });

    test('round-trip JSON serialization', () {
      const frame = ReferenceFrame(astronomicalBody: 'moon', alternateSystem: null);
      final json = frame.toJson();
      final restored = ReferenceFrame.fromJson(json);
      expect(restored.astronomicalBody, 'moon');
      expect(restored.alternateSystem, isNull);
    });

    test('round-trip JSON with alternate system', () {
      const frame = ReferenceFrame(astronomicalBody: 'mars', alternateSystem: 'sim-env-1');
      final json = frame.toJson();
      final restored = ReferenceFrame.fromJson(json);
      expect(restored.astronomicalBody, 'mars');
      expect(restored.alternateSystem, 'sim-env-1');
    });

    test('equality: same values are equal', () {
      const a = ReferenceFrame(astronomicalBody: 'earth');
      const b = ReferenceFrame(astronomicalBody: 'earth');
      expect(a, equals(b));
    });

    test('equality: different values are not equal', () {
      const a = ReferenceFrame(astronomicalBody: 'earth');
      const b = ReferenceFrame(astronomicalBody: 'moon');
      expect(a, isNot(equals(b)));
    });
  });
}
