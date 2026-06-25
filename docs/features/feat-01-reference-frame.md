---
title: "Specify Reference Frame for Geographic Location"
type: "feature"
interface_type: "m2m"
generation_mode: "subagent"
spec_source: "RFC 9179"
issue_id: 1
labels: ["feature", "geo-location"]
---

# Feature: Specify Reference Frame for Geographic Location

## Parent Epic
- [ ] #7 - Geographic Location: YANG Geo-Location Grouping(https://github.com/gintatkinson/dep-tst-devn-01/blob/main/docs/epics/epic-01-geo-location.md) (parent module container that owns the reference-frame sub-container)

## Description

The system must allow specification of a frame of reference that defines the context in which all location values in the geo-location grouping are interpreted. The reference frame identifies the astronomical body, geodetic system, and optionally an alternate coordinate system (such as a virtual reality or simulation). When no reference frame values are specified, the defaults apply: astronomical body is "earth" and geodetic datum is "wgs-84".

## UML Class Diagram

```mermaid
classDiagram
    class GeoLocation {
        <<component>>
    }
    class ReferenceFrame {
        +String astronomicalBody [0..1] {default: "earth"; pattern: ASCII 32..64, 91..126; SHOULD be lowercase; SHOULD omit leading "the"}
        +String alternateSystem [0..1] {if-feature: alternate-systems; modifies definition of all reference frame values}
    }
    class AlternateSystemsFeature {
        <<feature>>
        +Boolean supported [1]
    }
    GeoLocation *-- ReferenceFrame
    ReferenceFrame ..> AlternateSystemsFeature : conditioned-by
```

## Interface Requirements

### 1. Payload Schema (JSON Schema Example)

```json
{
  "geo-location": {
    "reference-frame": {
      "astronomical-body": "earth",
      "alternate-system": null
    }
  }
}
```

### 2. Validation & Constraints

- `astronomical-body`:
  - Type: `string`
  - Pattern: ASCII characters in ranges 32–64 and 91–126 only (`[ -@\[-\^_-~]*`)
  - Default: `"earth"`
  - SHOULD be lowercase (uppercase SHOULD be converted)
  - SHOULD NOT include leading "the" in the name
  - Defined by the International Astronomical Union (IAU) or by the alternate system if `alternate-system` is present
  - No additional min/max length constraints specified in schema

- `alternate-system`:
  - Type: `string`
  - Conditional: present only when the `alternate-systems` YANG feature is supported
  - When present: modifies the definition (but not the type) of all other values in `reference-frame`
  - When absent: implies the natural universe is the system
  - No additional constraints specified in schema

### 3. Logical Operations & Interface Messages

- **Read Reference Frame** (`GET /reference-frame`): Returns the current reference frame values including `astronomical-body` and optionally `alternate-system`.
- **Write Reference Frame** (`PUT /reference-frame`): Sets `astronomical-body` and/or `alternate-system`. If `alternate-system` is written when `alternate-systems` feature is not supported, the system MUST reject with a feature-not-supported error.

### 4. Logical Exception States & Validation Failures

- **Feature-not-supported error**: `alternate-system` provided but `alternate-systems` feature not enabled on device.
- **Pattern violation**: `astronomical-body` value contains characters outside ASCII ranges 32–64 or 91–126.
- **Missing context**: Consumer reads `reference-frame` but no values are set; system returns default values (`astronomical-body: "earth"`).

## Given-When-Then Acceptance Criteria

**Scenario 1: Default reference frame (earth)**
```
Given a geo-location instance with no reference-frame values set
When the system reads the reference-frame
Then astronomical-body returns "earth" as the default value
```

**Scenario 2: Non-earth astronomical body specified**
```
Given a geo-location instance
When astronomical-body is set to "moon"
Then the system stores the value "moon" and all location values are interpreted in the context of the Moon
```

**Scenario 3: Alternate system specified (feature enabled)**
```
Given a device that supports the alternate-systems feature
When alternate-system is set to a non-empty string value
Then the system accepts the value and the definition of all reference-frame values is modified by the alternate system
```

**Scenario 4: Alternate system rejected (feature not enabled)**
```
Given a device that does NOT support the alternate-systems feature
When alternate-system is provided in a write operation
Then the system rejects the operation with a feature-not-supported error
```

**Scenario 5: Invalid astronomical-body pattern**
```
Given a geo-location instance
When astronomical-body is set to a value containing control characters (ASCII 0–31 or 65–90)
Then the system rejects the value with a pattern constraint violation error
```

**Scenario 6: Case normalization recommendation**
```
Given a geo-location instance
When astronomical-body is set to "Earth" (uppercase)
Then the system SHOULD convert the value to lowercase "earth" per the SHOULD constraint
```

**Scenario 7: "the" prefix omission**
```
Given a geo-location instance
When astronomical-body is set to "the moon"
Then the system SHOULD store "moon" (omitting the leading "the") per the SHOULD constraint
```

## Specification Context (Verbatim)

> "The frame of reference ('reference-frame') defines what the location values refer to and their meaning. The referred-to object can be any astronomical body. It could be a planet such as Earth or Mars, a moon such as Enceladus, an asteroid such as Ceres, or even a comet such as 1P/Halley. This value is specified in 'astronomical-body' and is defined by the International Astronomical Union <http://www.iau.org>. The default 'astronomical-body' value is 'earth'."
>
> "Finally, we define an optional feature that allows for changing the system for which the above values are defined. This optional feature adds an 'alternate-system' value to the reference frame. This value is normally not present, which implies the natural universe is the system. The use of this value is intended to allow for creating virtual realities or perhaps alternate coordinate systems. The definition of alternate systems is outside the scope of this document."
>
> — RFC 9179, Section 2.1

## 4. Source References
Structural Schema: [ietf-geo-location@2022-02-11.yang](https://raw.githubusercontent.com/YangModels/yang/main/standard/ietf/RFC/ietf-geo-location%402022-02-11.yang)
Normative Specification: [RFC 9179 — A YANG Grouping for Geographic Locations](https://www.rfc-editor.org/rfc/rfc9179.html)

## 5. Logical UI & Layout Bindings
- **Target LUI Component:** PropertyGrid
- **Target Layout Container ID:** TBD (pending logical-layout.json definition)
- **Data Source Bindings:** TBD (pending logical-layout.json definition)
