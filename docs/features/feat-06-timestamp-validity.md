---
title: "Track Location Timestamp and Validity Expiration"
type: "feature"
interface_type: "m2m"
generation_mode: "subagent"
spec_source: "RFC 9179"
issue_id: 6
labels: ["feature", "geo-location"]
---

# Feature: Track Location Timestamp and Validity Expiration

## Parent Epic
- [ ] #7 - Geographic Location: YANG Geo-Location Grouping(https://github.com/gintatkinson/dep-tst-devn-01/blob/main/docs/epics/epic-01-geo-location.md) (parent module container that owns timestamp and valid-until leaf nodes)

## Description

The system must allow recording of when a location was captured (`timestamp`) and optionally until when that location data remains valid (`valid-until`). Both are expressed as RFC 3339 date-and-time values (YANG type `yang:date-and-time`). When `valid-until` is absent, the location data has no specific expiration. These fields enable consumers to reason about the currency and validity of location data, particularly for objects that may move or for data that becomes stale over time.

## UML Class Diagram

```mermaid
classDiagram
    class GeoLocation {
        +String timestamp [0..1] {type: yang:date-and-time; semantics: reference time when location was recorded}
        +String validUntil [0..1] {type: yang:date-and-time; semantics: expiration time of this location data; absent = no expiration}
    }
```

## Interface Requirements

### 1. Payload Schema (JSON Schema Example)

```json
{
  "geo-location": {
    "timestamp": "2022-02-11T00:00:00Z",
    "valid-until": "2022-12-31T23:59:59Z"
  }
}
```

### 2. Validation & Constraints

- `timestamp`:
  - Type: `yang:date-and-time` (RFC 3339 date-and-time string)
  - Optional — when absent, no recording time is associated with the location
  - Semantics: the reference time at which the location was recorded
  - Used as the reference time for the velocity vector values (if present)

- `valid-until`:
  - Type: `yang:date-and-time` (RFC 3339 date-and-time string)
  - Optional — when absent, the geo-location has no specific expiration time
  - Semantics: the timestamp after which this geo-location data is considered expired
  - When present: consumers SHOULD treat location data as invalid after this time
  - No explicit constraint that `valid-until` must be after `timestamp` in the schema — consumer responsibility

### 3. Logical Operations & Interface Messages

- **Write Timestamp** (`PUT /geo-location/timestamp`): Records the time at which this location was captured.
- **Write Valid-Until** (`PUT /geo-location/valid-until`): Sets the expiration time of the location data.
- **Read Temporal Attributes** (`GET /geo-location`): Returns `timestamp` and `valid-until` if present.
- **Check Expiry** (consumer-side): Consumer compares current time against `valid-until`; if current time exceeds `valid-until`, the location data is considered expired.

### 4. Logical Exception States & Validation Failures

- **Expired location**: Current time exceeds `valid-until` — location data is expired; consumers SHOULD NOT use the location values for real-time decisions.
- **No expiration**: `valid-until` absent — location has indefinite validity; consumer must apply its own staleness policy.
- **No timestamp**: `timestamp` absent — recording time unknown; consumers cannot determine data age.
- **Invalid date-time format**: `timestamp` or `valid-until` provided in a format other than RFC 3339 — MUST be rejected with a type validation error.
- **valid-until before timestamp**: `valid-until` is earlier than `timestamp` — schema does not prohibit this but it is semantically invalid; consumer should treat the location as immediately expired.

## Given-When-Then Acceptance Criteria

**Scenario 1: Timestamp recorded**
```
Given a geo-location instance
When timestamp is set to "1969-07-21T02:56:15Z"
Then the system stores the value and associates it as the reference time for the location data
```

**Scenario 2: Valid-until set — location has expiration**
```
Given a geo-location instance with a timestamp
When valid-until is set to "2022-12-31T23:59:59Z"
Then the system stores the expiration time; consumers SHOULD treat the location as expired after that time
```

**Scenario 3: valid-until absent — no expiration**
```
Given a geo-location instance
When valid-until is not provided
Then the system treats the location as having no specific expiration time
```

**Scenario 4: Expired location detected**
```
Given a geo-location instance with valid-until set to a past date-time
When a consumer reads the location data and compares valid-until to the current time
Then the consumer determines the location is expired and SHOULD NOT use the values for real-time purposes
```

**Scenario 5: Invalid date-time format rejected**
```
Given a geo-location instance
When timestamp is set to "21/07/1969" (non-RFC-3339 format)
Then the system rejects the value with a type validation error
```

**Scenario 6: Timestamp used as velocity reference time**
```
Given a geo-location instance with both timestamp and velocity values set
When a consumer reads the data
Then the consumer interprets the velocity vector as representing the object's motion at the time given by timestamp
```

**Scenario 7: valid-until before timestamp (semantic invalidity)**
```
Given a geo-location instance with timestamp "2022-02-11T00:00:00Z"
When valid-until is set to "2022-02-10T00:00:00Z" (before timestamp)
Then the system stores the value (no schema-level rejection) but the location is semantically immediately expired
```

## Specification Context (Verbatim)

> "leaf timestamp { type yang:date-and-time; description \"Reference time when location was recorded.\"; }"
>
> "leaf valid-until { type yang:date-and-time; description \"The timestamp for which this geo-location is valid until. If unspecified, the geo-location has no specific expiration time.\"; }"
>
> — RFC 9179, Section 3 (YANG Module), `ietf-geo-location@2022-02-11.yang`

## 4. Source References
Structural Schema: [ietf-geo-location@2022-02-11.yang](https://raw.githubusercontent.com/YangModels/yang/main/standard/ietf/RFC/ietf-geo-location%402022-02-11.yang)
Normative Specification: [RFC 9179 — A YANG Grouping for Geographic Locations](https://www.rfc-editor.org/rfc/rfc9179.html)

## 5. Logical UI & Layout Bindings
- **Target LUI Component:** PropertyGrid
- **Target Layout Container ID:** TBD (pending logical-layout.json definition)
- **Data Source Bindings:** TBD (pending logical-layout.json definition)
