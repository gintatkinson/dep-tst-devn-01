import 'package:app_flutter/domain/geodetic_system.dart';

class GeodeticSystemValidationResult {
  final bool isValid;
  final GeodeticSystem normalizedSystem;
  final String? error;

  const GeodeticSystemValidationResult.valid(this.normalizedSystem)
      : isValid = true,
        error = null;

  const GeodeticSystemValidationResult.invalid({
    required GeodeticSystem system,
    required String this.error,
  })  : isValid = false,
        normalizedSystem = system;
}

final _asciiPattern = RegExp(r'^[ -@\[-~]*$');

GeodeticSystemValidationResult validateGeodeticSystem(
  GeodeticSystem system, {
  required bool isCartesian,
}) {
  String datum = system.geodeticDatum;

  // Default normalization: if empty or 'wgs-84', normalize to 'wgs-84'
  if (datum.isEmpty || datum == 'wgs-84') {
    datum = 'wgs-84';
  }

  // Whitespace-only guard (must run before space-to-dash so '   ' is caught)
  if (datum.trim().isEmpty) {
    datum = 'wgs-84';
  }

  // Space-to-dash normalization
  datum = datum.replaceAll(' ', '-');

  // ASCII pattern check: reject if characters outside ranges 32–64 and 91–126
  if (!_asciiPattern.hasMatch(datum)) {
    return GeodeticSystemValidationResult.invalid(
      system: system,
      error: 'pattern constraint violation: geodetic-datum contains invalid characters',
    );
  }

  // Max length 32 guard
  if (datum.length > 32) {
    return GeodeticSystemValidationResult.invalid(
      system: system,
      error: 'geodetic-datum exceeds maximum length of 32 characters',
    );
  }

  // height-accuracy + Cartesian rejection
  if (isCartesian && system.heightAccuracy != null) {
    return GeodeticSystemValidationResult.invalid(
      system: system,
      error: 'height-accuracy is not valid for Cartesian coordinate systems',
    );
  }

  // Negative accuracy rejection
  if ((system.coordAccuracy != null && system.coordAccuracy! < 0) ||
      (system.heightAccuracy != null && system.heightAccuracy! < 0)) {
    return GeodeticSystemValidationResult.invalid(
      system: system,
      error: 'accuracy must be non-negative',
    );
  }

  bool _hasMaxFractionDigits(double value, int max) {
    final str = value.toStringAsFixed(10);
    final dotIndex = str.indexOf('.');
    if (dotIndex == -1) return true;
    final fractional = str.substring(dotIndex + 1);
    final trimmed = fractional.replaceAll(RegExp(r'0+$'), '');
    return trimmed.length <= max;
  }

  if (system.coordAccuracy != null && !_hasMaxFractionDigits(system.coordAccuracy!, 6)) {
    return GeodeticSystemValidationResult.invalid(
      system: system,
      error: 'coord-accuracy: at most 6 fractional digits allowed',
    );
  }
  if (system.heightAccuracy != null && !_hasMaxFractionDigits(system.heightAccuracy!, 6)) {
    return GeodeticSystemValidationResult.invalid(
      system: system,
      error: 'height-accuracy: at most 6 fractional digits allowed',
    );
  }

  final normalized = GeodeticSystem(
    geodeticDatum: datum,
    coordAccuracy: system.coordAccuracy,
    heightAccuracy: system.heightAccuracy,
  );

  return GeodeticSystemValidationResult.valid(normalized);
}
