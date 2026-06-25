---
title: "Record Ellipsoidal Coordinates for Geographic Location"
type: "feature"
interface_type: "m2m"
generation_mode: "subagent"
spec_source: "RFC 9179"
issue_id: 3
labels: ["feature", "geo-location"]
---

# Feature: Record Ellipsoidal Coordinates for Geographic Location

## Parent Epic
- [ ] #7 - Geographic Location: YANG Geo-Location Grouping(https://github.com/gintatkinson/dep-tst-devn-01/blob/main/docs/epics/epic-01-geo-location.md) (parent module container that owns the location choice — ellipsoid case)

## Description

The system must allow specification of a geographic location using ellipsoidal coordinates: latitude, longitude, and optionally height. These are specified as decimal degrees (latitude and longitude) and meters (height). The exact meaning of all values is determined by the geodetic datum in the reference frame. This is one of two mutually exclusive location representations (the other being Cartesian).

## UML Class Diagram

```mermaid
classDiagram
    class GeoLocation {
    }
    class LocationChoice {
        <<choice>>
    }
    class EllipsoidCase {
        <<choice>>
        +Real latitude [0..1] {type: decimal64; fraction-digits: 16; units: decimal degrees}
        +Real longitude [0..1] {type: decimal64; fraction-digits: 16; units: decimal degrees}
        +Real height [0..1] {type: decimal64; fraction-digits: 6; units: meters}
    }
    class CartesianCase {
        <<choice>>
    }
    GeoLocation *-- LocationChoice
    LocationChoice <|-- EllipsoidCase
    LocationChoice <|-- CartesianCase
```

## Interface Requirements

### 1. Payload Schema (JSON Schema Example)

```json
{
  "geo-location": {
    "latitude": 40.73297000000000,
    "longitude": -74.00769600000000,
    "height": 35.000000
  }
}
```

### 2. Validation & Constraints

- `latitude`:
  - Type: `decimal64`
  - Fraction digits: 16
  - Units: decimal degrees
  - No explicit range constraint in schema; meaning defined by the geodetic datum
  - Mutually exclusive with `x`, `y`, `z` (Cartesian case)

- `longitude`:
  - Type: `decimal64`
  - Fraction digits: 16
  - Units: decimal degrees
  - No explicit range constraint in schema; meaning defined by the geodetic datum
  - Mutually exclusive with `x`, `y`, `z` (Cartesian case)

- `height`:
  - Type: `decimal64`
  - Fraction digits: 6
  - Units: meters
  - Optional — latitude and longitude may be specified without height
  - Represents height from a reference 0 value; the "0" value and precision defined by the reference frame
  - Mutually exclusive with `x`, `y`, `z` (Cartesian case)

- **Choice constraint**: The `location` schema node is a YANG `choice`. If any ellipsoid leaf (`latitude`, `longitude`, `height`) is present, Cartesian leaves (`x`, `y`, `z`) MUST NOT be present, and vice versa.

### 3. Logical Operations & Interface Messages

- **Write Ellipsoidal Location** (`PUT /geo-location`): Sets `latitude` and/or `longitude` and optionally `height`. Providing any Cartesian coordinate simultaneously MUST be rejected.
- **Read Ellipsoidal Location** (`GET /geo-location`): Returns current `latitude`, `longitude`, and `height` if set.
- **Clear Location** (`DELETE /geo-location/latitude|longitude|height`): Removes ellipsoidal location values.

### 4. Logical Exception States & Validation Failures

- **Choice conflict**: Both ellipsoidal (`latitude`/`longitude`/`height`) and Cartesian (`x`/`y`/`z`) values provided simultaneously — MUST be rejected as a YANG choice violation.
- **Precision loss warning**: Consumer systems using `double` (e.g., W3C Geolocation API) may lose precision at the extremes of `decimal64` with 16 fraction digits.
- **No location set**: `location` choice is optional — both cases absent is valid; system returns no location data.

## Given-When-Then Acceptance Criteria

**Scenario 1: Valid latitude and longitude stored**
```
Given a geo-location instance with reference-frame set
When latitude is set to 40.7329700000000000 and longitude is set to -74.0076960000000000
Then the system stores both values with up to 16 decimal digits of precision
```

**Scenario 2: Optional height stored**
```
Given a geo-location instance with latitude and longitude set
When height is set to 35.000000
Then the system stores the height value in meters relative to the reference frame's 0-height definition
```

**Scenario 3: Location without height is valid**
```
Given a geo-location instance
When only latitude and longitude are set (no height)
Then the system accepts the values and returns them without height
```

**Scenario 4: Choice conflict rejected**
```
Given a geo-location instance
When both latitude and x (Cartesian) are provided in the same write operation
Then the system rejects the operation with a YANG choice constraint violation error
```

**Scenario 5: Meaning governed by geodetic datum**
```
Given a geo-location instance with geodetic-datum set to "me" (Moon) and astronomical-body "moon"
When latitude is set to 0.67409 and longitude to 23.47298
Then the system stores these coordinates and interprets them relative to the Mean Earth/Polar Axis lunar datum
```

**Scenario 6: No location is valid**
```
Given a geo-location instance
When neither ellipsoidal nor Cartesian location values are provided
Then the system accepts the instance as valid (location choice is optional)
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
