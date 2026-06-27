import 'package:app_flutter/domain/cartesian_coordinate.dart';

bool validateCartesianCoordinate(CartesianCoordinate coordinate) {
  return true;
}

bool validateLocationChoice(
    CartesianCoordinate? cart, Map<String, dynamic>? ellipsoidal) {
  if (cart == null && ellipsoidal == null) return true;
  if (cart != null && ellipsoidal == null) return true;
  if (cart == null && ellipsoidal != null) return true;
  return false;
}

bool validateHeightAccuracyWithCartesian(double? heightAccuracy) {
  return heightAccuracy == null;
}
