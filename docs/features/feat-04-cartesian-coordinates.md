---
title: "Record Cartesian Coordinates for Geographic Location"
type: "feature"
interface_type: "m2m"
generation_mode: "subagent"
spec_source: "RFC 9179"
issue_id: null
labels: ["feature", "geo-location"]
---

# Feature: Record Cartesian Coordinates for Geographic Location

## Parent Epic
- [ ] #TBD - Geographic Location: YANG Geo-Location Grouping (docs/epics/epic-01-geo-location.md) (parent module container that owns the location choice — cartesian case)

## Description

The system must allow specification of a geographic location using three-dimensional Cartesian coordinates: X, Y, and Z, all expressed in meters. The exact meaning of these coordinates is determined by the geodetic datum in the reference frame. This is one of two mutually exclusive location representations (the other being ellipsoidal). The `height-accuracy` field from the geodetic system MUST NOT be used when Cartesian coordinates are in effect.

## UML Class Diagram

```mermaid
classDiagram
    class GeoLocation {
    }
    class LocationChoice {
        <<choice>>
    }
    class CartesianCase {
        <<choice>>
        +Real x [0..1] {type: decimal64; fraction-digits: 6; units: meters}
        +Real y [0..1] {type: decimal64; fraction-digits: 6; units: meters}
        +Real z [0..1] {type: decimal64; fraction-digits: 6; units: meters}
    }
    class EllipsoidCase {
        <<choice>>
    }
    GeoLocation *-- LocationChoice
    LocationChoice <|-- CartesianCase
    LocationChoice <|-- EllipsoidCase
```

## Interface Requirements

### 1. Payload Schema (JSON Schema Example)

```json
{
  "geo-location": {
    "x": 4517590.123456,
    "y": 616801.654321,
    "z": 4413583.987654
  }
}
```

### 2. Validation & Constraints

- `x`:
  - Type: `decimal64`
  - Fraction digits: 6
  - Units: meters
  - Meaning defined by the reference frame's geodetic datum
  - Mutually exclusive with `latitude`, `longitude`, `height` (ellipsoid case)

- `y`:
  - Type: `decimal64`
  - Fraction digits: 6
  - Units: meters
  - Meaning defined by the reference frame's geodetic datum
  - Mutually exclusive with `latitude`, `longitude`, `height` (ellipsoid case)

- `z`:
  - Type: `decimal64`
  - Fraction digits: 6
  - Units: meters
  - Meaning defined by the reference frame's geodetic datum
  - Mutually exclusive with `latitude`, `longitude`, `height` (ellipsoid case)

- **Choice constraint**: If any Cartesian leaf (`x`, `y`, `z`) is present, ellipsoidal leaves (`latitude`, `longitude`, `height`) MUST NOT be present.
- **height-accuracy inapplicability**: `height-accuracy` (from geodetic-system) is not used with Cartesian coordinates; its presence when Cartesian is active is a constraint violation.
- **coord-accuracy applicability**: `coord-accuracy` applies to the X, Y, Z components when Cartesian coordinates are in use.

### 3. Logical Operations & Interface Messages

- **Write Cartesian Location** (`PUT /geo-location`): Sets `x`, `y`, and/or `z`. Providing any ellipsoidal coordinate simultaneously MUST be rejected.
- **Read Cartesian Location** (`GET /geo-location`): Returns current `x`, `y`, `z` values if set.
- **Clear Location** (`DELETE /geo-location/x|y|z`): Removes Cartesian location values.

### 4. Logical Exception States & Validation Failures

- **Choice conflict**: Both Cartesian (`x`/`y`/`z`) and ellipsoidal (`latitude`/`longitude`/`height`) values provided simultaneously — MUST be rejected as a YANG choice violation.
- **height-accuracy with Cartesian**: `height-accuracy` provided alongside Cartesian coordinates — MUST be rejected.
- **No location set**: Both cases absent is valid — the location choice is optional.

## Given-When-Then Acceptance Criteria

**Scenario 1: Valid Cartesian coordinates stored**
```
Given a geo-location instance with reference-frame set
When x is set to 4517590.123456, y to 616801.654321, and z to 4413583.987654
Then the system stores all three values in meters with up to 6 decimal digits of precision
```

**Scenario 2: Meaning governed by geodetic datum**
```
Given a geo-location instance with a specific geodetic-datum set
When x, y, z are provided
Then the system interprets the values according to that geodetic datum's Cartesian coordinate definition
```

**Scenario 3: Choice conflict rejected**
```
Given a geo-location instance
When both x (Cartesian) and latitude (ellipsoidal) are provided in the same write operation
Then the system rejects the operation with a YANG choice constraint violation error
```

**Scenario 4: height-accuracy rejected with Cartesian**
```
Given a geo-location instance using Cartesian coordinates
When height-accuracy is also provided
Then the system rejects the combination with a constraint violation (height-accuracy not applicable to Cartesian)
```

**Scenario 5: coord-accuracy applies to Cartesian**
```
Given a geo-location instance using Cartesian coordinates
When coord-accuracy is set to 0.001000
Then the system applies that accuracy value to the X, Y, Z components
```

**Scenario 6: Partial Cartesian (subset of x, y, z)**
```
Given a geo-location instance
When only x and y are provided without z
Then the system stores x and y; z is absent; the instance is valid (all Cartesian leaves are optional)
```

## Specification Context (Verbatim)

> "This is the location on, or relative to, the astronomical object. It is specified using two or three coordinate values. These values are given either as 'latitude', 'longitude', and an optional 'height', or as Cartesian coordinates of 'x', 'y', and 'z'. For the standard location choice, 'latitude' and 'longitude' are specified as decimal degrees, and the 'height' value is in fractions of meters. For the Cartesian choice, 'x', 'y', and 'z' are in fractions of meters. In both choices, the exact meanings of all the values are defined by the 'geodetic-datum' value in Section 2.1."
>
> — RFC 9179, Section 2.2

## 4. Source References
Structural Schema: [ietf-geo-location@2022-02-11.yang](https://raw.githubusercontent.com/YangModels/yang/main/standard/ietf/RFC/ietf-geo-location%402022-02-11.yang)
Normative Specification: [RFC 9179 — A YANG Grouping for Geographic Locations](https://www.rfc-editor.org/rfc/rfc9179.html)

## 5. Logical UI & Layout Bindings
- **Target LUI Component:** PropertyGrid
- **Target Layout Container ID:** TBD (pending logical-layout.json definition)
- **Data Source Bindings:** TBD (pending logical-layout.json definition)
