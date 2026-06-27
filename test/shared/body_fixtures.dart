// Copyright Gint Atkinson, gint.atkinson@gmail.com
// Shared astronomical body constants for test fixtures.
// Source: docs/features/feat-01-reference-frame.md (RFC 9179)

const kTestBodyEarth = 'earth';
const kTestBodyMoon = 'moon';
const kTestBodyMars = 'mars';
const kTestBodyVenus = 'venus';

// Normalization test inputs
const kTestBodyEarthUpper = 'Earth';
const kTestBodyEarthTab = 'earth\t';
const kTestBodyTheMoon = 'the moon';

// Invalid pattern test inputs (control chars, non-ASCII)
const kTestBodyBadControl = 'bad\x01body';
const kTestBodyNonAscii = 'caf\u00E9';
