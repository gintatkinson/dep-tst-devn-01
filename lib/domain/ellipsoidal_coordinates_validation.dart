import 'package:app_flutter/domain/ellipsoidal_coordinates.dart';

class EllipsoidalCoordinatesValidationResult {
  final bool isValid;
  final String? error;

  const EllipsoidalCoordinatesValidationResult.valid()
      : isValid = true,
        error = null;

  const EllipsoidalCoordinatesValidationResult.invalid(this.error)
      : isValid = false;
}

bool _hasMaxFractionDigits(double value, int max) {
  final str = value.toString();
  final dotIndex = str.indexOf('.');
  if (dotIndex == -1) return true;
  final fractional = str.substring(dotIndex + 1);
  final trimmed = fractional.replaceAll(RegExp(r'0+$'), '');
  return trimmed.length <= max;
}

EllipsoidalCoordinatesValidationResult validateEllipsoidalCoordinates(
  EllipsoidalCoordinates coords,
) {
  if (coords.latitude != null && !_hasMaxFractionDigits(coords.latitude!, 16)) {
    return const EllipsoidalCoordinatesValidationResult.invalid(
      'latitude: at most 16 fractional digits allowed',
    );
  }
  if (coords.longitude != null && !_hasMaxFractionDigits(coords.longitude!, 16)) {
    return const EllipsoidalCoordinatesValidationResult.invalid(
      'longitude: at most 16 fractional digits allowed',
    );
  }
  if (coords.height != null && !_hasMaxFractionDigits(coords.height!, 6)) {
    return const EllipsoidalCoordinatesValidationResult.invalid(
      'height: at most 6 fractional digits allowed',
    );
  }
  return const EllipsoidalCoordinatesValidationResult.valid();
}
