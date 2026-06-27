class CartesianCoordinate {
  final double? x;
  final double? y;
  final double? z;

  const CartesianCoordinate({
    this.x,
    this.y,
    this.z,
  });

  Map<String, dynamic> toJson() => {
        if (x != null) 'x': x,
        if (y != null) 'y': y,
        if (z != null) 'z': z,
      };

  factory CartesianCoordinate.fromJson(Map<String, dynamic> json) {
    return CartesianCoordinate(
      x: (json['x'] as num?)?.toDouble(),
      y: (json['y'] as num?)?.toDouble(),
      z: (json['z'] as num?)?.toDouble(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartesianCoordinate &&
          x == other.x &&
          y == other.y &&
          z == other.z;

  @override
  int get hashCode => Object.hash(x, y, z);

  @override
  String toString() => 'CartesianCoordinate(x: $x, y: $y, z: $z)';
}
