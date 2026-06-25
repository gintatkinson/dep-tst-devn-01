/// @realizes UML::ReferenceFrame
///
/// Immutable domain type representing the reference frame for geographic
/// location values as specified in RFC 9179 §2.1.
///
/// Defaults: [astronomicalBody] = "earth", [alternateSystem] = null.
class ReferenceFrame {
  /// The astronomical body defining the coordinate context.
  /// Defined by the IAU. Default: "earth".
  final String astronomicalBody;

  /// Optional alternate system identifier (e.g. virtual reality environment).
  /// Present only when the alternate-systems feature is supported.
  final String? alternateSystem;

  const ReferenceFrame({
    this.astronomicalBody = 'earth',
    this.alternateSystem,
  });

  /// Deserializes a [ReferenceFrame] from a JSON map.
  factory ReferenceFrame.fromJson(Map<String, dynamic> json) {
    return ReferenceFrame(
      astronomicalBody: (json['astronomical-body'] as String?) ?? 'earth',
      alternateSystem: json['alternate-system'] as String?,
    );
  }

  /// Serializes this [ReferenceFrame] to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'astronomical-body': astronomicalBody,
      if (alternateSystem != null) 'alternate-system': alternateSystem,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReferenceFrame &&
          runtimeType == other.runtimeType &&
          astronomicalBody == other.astronomicalBody &&
          alternateSystem == other.alternateSystem;

  @override
  int get hashCode => Object.hash(astronomicalBody, alternateSystem);

  @override
  String toString() =>
      'ReferenceFrame(astronomicalBody: $astronomicalBody, alternateSystem: $alternateSystem)';
}
