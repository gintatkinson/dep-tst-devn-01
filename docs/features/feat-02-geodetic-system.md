---
title: "Define Geodetic System and Coordinate Accuracy"
type: "feature"
interface_type: "m2m"
generation_mode: "subagent"
spec_source: "RFC 9179"
issue_id: null
labels: ["feature", "geo-location"]
---

# Feature: Define Geodetic System and Coordinate Accuracy

## Parent Epic
- [ ] #TBD - Geographic Location: YANG Geo-Location Grouping (docs/epics/epic-01-geo-location.md) (parent module container that owns the geodetic-system sub-container within reference-frame)

## Description

Within the reference frame, the system must allow specification of the geodetic datum that defines the mathematical meaning of all coordinate values (latitude/longitude or Cartesian), as well as optional overrides for the precision of those coordinates. The geodetic datum defaults to "wgs-84" when the astronomical body is Earth. Coordinate accuracy and height accuracy may optionally override the default accuracy implied by the geodetic datum.

## UML Class Diagram

```mermaid
classDiagram
    class ReferenceFrame {
    }
    class GeodeticSystem {
        +String geodeticDatum [0..1] {pattern: ASCII 32..64, 91..126; spaces converted to dashes; SHOULD be lowercase; default for Earth: "wgs-84"; ref: RFC 9179 Section 6.1}
        +Real coordAccuracy [0..1] {type: decimal64; fraction-digits: 6; no units specified}
        +Real heightAccuracy [0..1] {type: decimal64; fraction-digits: 6; units: meters; not used with Cartesian coordinates}
    }
    ReferenceFrame *-- GeodeticSystem
```

## Interface Requirements

### 1. Payload Schema (JSON Schema Example)

```json
{
  "reference-frame": {
    "geodetic-system": {
      "geodetic-datum": "wgs-84",
      "coord-accuracy": 0.000001,
      "height-accuracy": 0.000001
    }
  }
}
```

### 2. Validation & Constraints

- `geodetic-datum`:
  - Type: `string`
  - Pattern: ASCII characters in ranges 32–64 and 91–126 only (`[ -@\[-\^_-~]*`)
  - SHOULD be lowercase
  - Spaces MUST be converted to dashes (`-`) per IANA registry restriction
  - Default for astronomical body "earth": `"wgs-84"` (World Geodetic System 1984)
  - IANA registry: "Geodetic System Values" under "YANG Geographic Location Parameters"
  - No explicit min/max length constraints in schema

- `coord-accuracy`:
  - Type: `decimal64`
  - Fraction digits: 6
  - No units specified
  - Applies to: latitude/longitude pair for ellipsoidal coordinates; X, Y, Z for Cartesian coordinates
  - Semantics: overrides default accuracy implied by the geodetic datum
  - Optional — when absent, accuracy is implied by the geodetic datum

- `height-accuracy`:
  - Type: `decimal64`
  - Fraction digits: 6
  - Units: `meters`
  - Applies to: ellipsoidal height only — MUST NOT be used with Cartesian coordinates
  - Semantics: overrides default height accuracy implied by the geodetic datum
  - Optional — when absent, height accuracy is implied by the geodetic datum

### 3. Logical Operations & Interface Messages

- **Read Geodetic System** (`GET /reference-frame/geodetic-system`): Returns `geodetic-datum`, `coord-accuracy`, `height-accuracy` values.
- **Write Geodetic System** (`PUT /reference-frame/geodetic-system`): Sets any combination of `geodetic-datum`, `coord-accuracy`, `height-accuracy`. If `height-accuracy` is written when Cartesian coordinates are in use, the system MUST reject with a constraint violation.
- **Read IANA Registry Value** (informational): Consumers MAY validate `geodetic-datum` against the IANA "Geodetic System Values" registry.

### 4. Logical Exception States & Validation Failures

- **Pattern violation**: `geodetic-datum` contains characters outside ASCII ranges 32–64 or 91–126.
- **Space-in-datum error**: `geodetic-datum` value contains a space instead of a dash (MUST be dashes per IANA registry).
- **height-accuracy with Cartesian**: `height-accuracy` is specified when the location choice is Cartesian — value is invalid in this context.
- **Negative accuracy**: `coord-accuracy` or `height-accuracy` set to a negative value — no explicit schema constraint but semantically invalid (accuracy cannot be negative).

## Given-When-Then Acceptance Criteria

**Scenario 1: Default geodetic datum for Earth**
```
Given a geo-location instance with astronomical-body set to "earth" and no geodetic-datum specified
When the system reads geodetic-datum
Then the system returns "wgs-84" as the implied default
```

**Scenario 2: Custom geodetic datum specified**
```
Given a geo-location instance
When geodetic-datum is set to "me" (Mean Earth/Polar Axis for Moon)
Then the system stores "me" and all coordinate values are interpreted according to that datum
```

**Scenario 3: Invalid geodetic-datum pattern**
```
Given a geo-location instance
When geodetic-datum is set to a value containing control characters (outside ASCII 32–64, 91–126)
Then the system rejects the value with a pattern constraint violation error
```

**Scenario 4: Space in geodetic-datum value**
```
Given a geo-location instance
When geodetic-datum is set to "wgs 84" (with a space)
Then the system MUST reject or normalize the value to "wgs-84" (spaces converted to dashes per IANA registry)
```

**Scenario 5: coord-accuracy overrides datum default**
```
Given a geo-location instance with geodetic-datum "wgs-84"
When coord-accuracy is set to 0.000010
Then the system stores the value and coordinate accuracy is interpreted as 0.000010 (overriding wgs-84 default)
```

**Scenario 6: height-accuracy invalid with Cartesian coordinates**
```
Given a geo-location instance using Cartesian coordinates (x, y, z)
When height-accuracy is provided
Then the system rejects the value with a constraint violation (height-accuracy not applicable to Cartesian)
```

**Scenario 7: height-accuracy valid with ellipsoidal coordinates**
```
Given a geo-location instance using ellipsoidal coordinates (latitude, longitude, height)
When height-accuracy is set to 0.500000
Then the system stores 0.500000 meters as the height accuracy override
```

## Specification Context (Verbatim)

> "In addition to identifying the astronomical body, we also need to define the meaning of the coordinates (e.g., latitude and longitude) and the definition of 0-height. This is done with a 'geodetic-datum' value. The default value for 'geodetic-datum' is 'wgs-84' (i.e., the World Geodetic System [WGS84]), which is used by the Global Positioning System (GPS) among many others. We define an IANA registry for specifying standard values for the 'geodetic-datum'. In addition to the 'geodetic-datum' value, we allow overriding the coordinate and height accuracy using 'coord-accuracy' and 'height-accuracy', respectively. When specified, these values override the defaults implied by the 'geodetic-datum' value."
>
> — RFC 9179, Section 2.1

## 4. Source References
Structural Schema: [ietf-geo-location@2022-02-11.yang](https://raw.githubusercontent.com/YangModels/yang/main/standard/ietf/RFC/ietf-geo-location%402022-02-11.yang)
Normative Specification: [RFC 9179 — A YANG Grouping for Geographic Locations](https://www.rfc-editor.org/rfc/rfc9179.html)

## 5. Logical UI & Layout Bindings
- **Target LUI Component:** PropertyGrid
- **Target Layout Container ID:** TBD (pending logical-layout.json definition)
- **Data Source Bindings:** TBD (pending logical-layout.json definition)
