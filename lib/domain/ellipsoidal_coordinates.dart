class EllipsoidalCoordinates {
  final double? latitude;
  final double? longitude;
  final double? height;

  const EllipsoidalCoordinates({
    this.latitude,
    this.longitude,
    this.height,
  });

  factory EllipsoidalCoordinates.fromJson(Map<String, dynamic> json) {
    return EllipsoidalCoordinates(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (height != null) 'height': height,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EllipsoidalCoordinates &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          height == other.height;

  @override
  int get hashCode => Object.hash(latitude, longitude, height);

  @override
  String toString() =>
      'EllipsoidalCoordinates(latitude: $latitude, longitude: $longitude, height: $height)';
}
