class GeodeticSystem {
  final String geodeticDatum;
  final double? coordAccuracy;
  final double? heightAccuracy;

  const GeodeticSystem({
    this.geodeticDatum = 'wgs-84',
    this.coordAccuracy,
    this.heightAccuracy,
  });

  factory GeodeticSystem.fromJson(Map<String, dynamic> json) {
    return GeodeticSystem(
      geodeticDatum: ((json['geodetic-datum'] as String?) ?? 'wgs-84').replaceAll(' ', '-'),
      coordAccuracy: (json['coord-accuracy'] as num?)?.toDouble(),
      heightAccuracy: (json['height-accuracy'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'geodetic-datum': geodeticDatum,
      if (coordAccuracy != null) 'coord-accuracy': coordAccuracy,
      if (heightAccuracy != null) 'height-accuracy': heightAccuracy,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeodeticSystem &&
          runtimeType == other.runtimeType &&
          geodeticDatum == other.geodeticDatum &&
          coordAccuracy == other.coordAccuracy &&
          heightAccuracy == other.heightAccuracy;

  @override
  int get hashCode => Object.hash(geodeticDatum, coordAccuracy, heightAccuracy);

  @override
  String toString() =>
      'GeodeticSystem(geodeticDatum: $geodeticDatum, coordAccuracy: $coordAccuracy, heightAccuracy: $heightAccuracy)';
}
