class AttributeDefinition {
  final String key;
  final String label;
  final String type; // 'double' | 'int' | 'string' | 'enum'
  final String sectionGroup;
  final List<String>? options;
  final bool isRequired;
  final String? regexPattern;
  final num? minValue;
  final num? maxValue;

  const AttributeDefinition({
    required this.key,
    required this.label,
    required this.type,
    required this.sectionGroup,
    this.options,
    this.isRequired = false,
    this.regexPattern,
    this.minValue,
    this.maxValue,
  });

  factory AttributeDefinition.fromJson(Map<String, dynamic> json) {
    return AttributeDefinition(
      key: json['key'] as String,
      label: json['label'] as String,
      type: json['type'] as String,
      sectionGroup: json['sectionGroup'] as String,
      options: (json['options'] as List<dynamic>?)?.map((e) => e as String).toList(),
      isRequired: json['isRequired'] as bool? ?? false,
      regexPattern: json['regexPattern'] as String?,
      minValue: json['minValue'] as num?,
      maxValue: json['maxValue'] as num?,
    );
  }
}

const List<AttributeDefinition> defaultCoordinateAttributes = [
  AttributeDefinition(
    key: 'roomName',
    label: 'Room Identifier',
    type: 'string',
    sectionGroup: 'Alternate',
    isRequired: false,
  ),
  AttributeDefinition(
    key: 'gridRow',
    label: 'Grid Row',
    type: 'int',
    sectionGroup: 'Alternate',
    isRequired: false,
  ),
  AttributeDefinition(
    key: 'gridColumn',
    label: 'Grid Column',
    type: 'int',
    sectionGroup: 'Alternate',
    isRequired: false,
  ),
  AttributeDefinition(
    key: 'maxVoltage',
    label: 'Max Voltage (V)',
    type: 'double',
    sectionGroup: 'Alternate',
    isRequired: false,
  ),
  AttributeDefinition(
    key: 'maxAllocatedPower',
    label: 'Max Allocated Power (W)',
    type: 'double',
    sectionGroup: 'Alternate',
    isRequired: false,
  ),
  AttributeDefinition(
    key: 'countryCode',
    label: 'Country Code (ISO-2)',
    type: 'string',
    sectionGroup: 'Alternate',
    isRequired: false,
  ),
  AttributeDefinition(
    key: 'locationType',
    label: 'Location Hierarchy Type',
    type: 'enum',
    sectionGroup: 'Alternate',
    options: ['site', 'room', 'building', 'invalid-test-option'],
    isRequired: false,
  ),
];

const List<AttributeDefinition> defaultGeodeticAttributes = [
  AttributeDefinition(
    key: 'geodetic-datum',
    label: 'Geodetic Datum',
    type: 'string',
    sectionGroup: 'Location',
    regexPattern: r'^[ -@\[-~]*$',
  ),
  AttributeDefinition(
    key: 'coord-accuracy',
    label: 'Coord Accuracy',
    type: 'double',
    sectionGroup: 'Location',
    minValue: 0,
  ),
  AttributeDefinition(
    key: 'height-accuracy',
    label: 'Height Accuracy',
    type: 'double',
    sectionGroup: 'Location',
    minValue: 0,
  ),
];

const List<AttributeDefinition> defaultEllipsoidalAttributes = [
  AttributeDefinition(
    key: 'latitude',
    label: 'Latitude',
    type: 'double',
    sectionGroup: 'Location',
  ),
  AttributeDefinition(
    key: 'longitude',
    label: 'Longitude',
    type: 'double',
    sectionGroup: 'Location',
  ),
  AttributeDefinition(
    key: 'height',
    label: 'Height (m)',
    type: 'double',
    sectionGroup: 'Location',
  ),
];

const List<AttributeDefinition> defaultCartesianAttributes = [
  AttributeDefinition(
    key: 'x',
    label: 'X (m)',
    type: 'double',
    sectionGroup: 'Cartesian',
  ),
  AttributeDefinition(
    key: 'y',
    label: 'Y (m)',
    type: 'double',
    sectionGroup: 'Cartesian',
  ),
  AttributeDefinition(
    key: 'z',
    label: 'Z (m)',
    type: 'double',
    sectionGroup: 'Cartesian',
  ),
];
