---
title: "Capture Velocity Vector for Objects in Motion"
type: "feature"
interface_type: "m2m"
generation_mode: "subagent"
spec_source: "RFC 9179"
issue_id: null
labels: ["feature", "geo-location"]
---

# Feature: Capture Velocity Vector for Objects in Motion

## Parent Epic
- [ ] #TBD - Geographic Location: YANG Geo-Location Grouping (docs/epics/epic-01-geo-location.md) (parent module container that owns the velocity sub-container)

## Description

The system must allow specification of a three-dimensional velocity vector for objects in relatively stable motion at the time the location is recorded. The vector components are v-north (towards true north), v-east (perpendicular right of true north), and v-up (away from center of mass), all in meters per second. These values enable derivation of two-dimensional heading and speed using defined formulas. The velocity container is optional — it need not be present for stationary objects.

## UML Class Diagram

```mermaid
classDiagram
    class GeoLocation {
    }
    class Velocity {
        +Real vNorth [0..1] {type: decimal64; fraction-digits: 12; units: meters per second; direction: towards true north per geodetic-system}
        +Real vEast [0..1] {type: decimal64; fraction-digits: 12; units: meters per second; direction: perpendicular right of true north per geodetic-system}
        +Real vUp [0..1] {type: decimal64; fraction-digits: 12; units: meters per second; direction: away from center of mass}
        +deriveSpeed(vNorth: Real, vEast: Real) Real
        +deriveHeading(vNorth: Real, vEast: Real) Real
    }
    GeoLocation *-- Velocity
```

## Interface Requirements

### 1. Payload Schema (JSON Schema Example)

```json
{
  "geo-location": {
    "velocity": {
      "v-north": 0.012345678901,
      "v-east": -0.005678901234,
      "v-up": 0.000000000001
    }
  }
}
```

### 2. Validation & Constraints

- `v-north`:
  - Type: `decimal64`
  - Fraction digits: 12
  - Units: meters per second
  - Direction: rate of change towards true north as defined by the geodetic system
  - Optional — when absent, motion component is unspecified

- `v-east`:
  - Type: `decimal64`
  - Fraction digits: 12
  - Units: meters per second
  - Direction: rate of change perpendicular to the right of true north as defined by the geodetic system
  - Optional — when absent, motion component is unspecified

- `v-up`:
  - Type: `decimal64`
  - Fraction digits: 12
  - Units: meters per second
  - Direction: rate of change away from center of mass (perpendicular to the plane defined by v-north and v-east)
  - Optional — when absent, motion component is unspecified

- **Derived values (informational, not stored)**:
  - `speed = √(v_north² + v_east²)` — two-dimensional speed in the horizontal plane
  - `heading = arctan(v_east / v_north)` — two-dimensional heading in radians

- **Applicability**: Intended for objects in "relatively stable motion" — not designed for tracking complex or high-frequency changing motion trajectories.

### 3. Logical Operations & Interface Messages

- **Write Velocity** (`PUT /geo-location/velocity`): Sets any combination of `v-north`, `v-east`, `v-up`.
- **Read Velocity** (`GET /geo-location/velocity`): Returns current velocity vector components.
- **Derive Speed/Heading** (consumer-side calculation): Consumers MAY derive 2D speed and heading from `v-north` and `v-east` using the RFC-defined formulas.

### 4. Logical Exception States & Validation Failures

- **Absent velocity for stationary object**: Velocity container not present — valid; object is assumed stationary or motion is unspecified.
- **Partial velocity vector**: Only some components set (e.g., only `v-north`) — valid; all three leaves are independently optional.
- **Stale velocity**: Velocity was recorded at `timestamp` time; if the object's motion has changed significantly since then, the velocity data may be outdated — consumer responsibility to check `timestamp`.

## Given-When-Then Acceptance Criteria

**Scenario 1: Full velocity vector stored**
```
Given a geo-location instance representing an object in motion
When v-north is set to 0.012345678901, v-east to -0.005678901234, and v-up to 0.000000000001
Then the system stores all three values with up to 12 decimal digits of precision in meters per second
```

**Scenario 2: Stationary object — velocity absent**
```
Given a geo-location instance representing a stationary object
When no velocity values are provided
Then the system accepts the instance as valid without any velocity data
```

**Scenario 3: Partial velocity vector is valid**
```
Given a geo-location instance
When only v-north is set
Then the system stores v-north; v-east and v-up remain absent; the instance is valid
```

**Scenario 4: Speed derivable from v-north and v-east**
```
Given a geo-location instance with v-north set to 3.0 and v-east set to 4.0
When a consumer calculates speed using speed = sqrt(v_north^2 + v_east^2)
Then the derived speed equals 5.0 meters per second
```

**Scenario 5: Heading derivable from v-north and v-east**
```
Given a geo-location instance with v-north set to 1.0 and v-east set to 1.0
When a consumer calculates heading using heading = arctan(v_east / v_north)
Then the derived heading equals arctan(1) = pi/4 radians (45 degrees from true north)
```

**Scenario 6: v-up direction is away from center of mass**
```
Given a geo-location instance
When v-up is set to a positive value
Then the system interprets the value as motion away from the astronomical body's center of mass
```

**Scenario 7: High-precision velocity for continental drift**
```
Given a geo-location instance tracking slow geophysical movement
When v-north is set to 0.000000000001 (1 picometer per second)
Then the system stores the value with 12 fraction digits of precision without truncation
```

## Specification Context (Verbatim)

> "Support is added for objects in relatively stable motion. For objects in relatively stable motion, the grouping provides a three-dimensional vector value. The components of the vector are 'v-north', 'v-east', and 'v-up', which are all given in fractional meters per second. The values 'v-north' and 'v-east' are relative to true north as defined by the reference frame for the astronomical body; 'v-up' is perpendicular to the plane defined by 'v-north' and 'v-east', and is pointed away from the center of mass. To derive the two-dimensional heading and speed, one would use the following formulas: speed = √(v_north² + v_east²), heading = arctan(v_east / v_north). For some applications that demand high accuracy and where the data is infrequently updated, this velocity vector can track very slow movement such as continental drift."
>
> — RFC 9179, Section 2.3

## 4. Source References
Structural Schema: [ietf-geo-location@2022-02-11.yang](https://raw.githubusercontent.com/YangModels/yang/main/standard/ietf/RFC/ietf-geo-location%402022-02-11.yang)
Normative Specification: [RFC 9179 — A YANG Grouping for Geographic Locations](https://www.rfc-editor.org/rfc/rfc9179.html)

## 5. Logical UI & Layout Bindings
- **Target LUI Component:** PropertyGrid
- **Target Layout Container ID:** TBD (pending logical-layout.json definition)
- **Data Source Bindings:** TBD (pending logical-layout.json definition)
