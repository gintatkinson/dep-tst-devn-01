import 'package:app_flutter/domain/reference_frame.dart';

/// @realizes UML::ReferenceFrame::validate
///
/// Result returned by [validateReferenceFrame].
/// On success [isValid] is true and [normalizedFrame] holds the
/// normalized (lowercased, "the "-stripped) [ReferenceFrame].
/// On failure [isValid] is false and [error] describes the violation.
class ReferenceFrameValidationResult {
  final bool isValid;
  final ReferenceFrame normalizedFrame;
  final String? error;

  const ReferenceFrameValidationResult.valid(this.normalizedFrame)
      : isValid = true,
        error = null;

  const ReferenceFrameValidationResult.invalid({
    required ReferenceFrame frame,
    required String this.error,
  })  : isValid = false,
        normalizedFrame = frame;
}

/// ASCII pattern per RFC 9179: ranges 32–64 and 91–126 only.
/// Excludes control characters (0–31) and uppercase letters (65–90).
final _asciiPattern = RegExp(r'^[ -@\[-~]*$');

/// Validates and normalizes a [ReferenceFrame] per feat-01 BDD scenarios.
///
/// [alternateSystemsFeatureEnabled] must reflect the runtime feature flag.
///
/// Normalization (SHOULD rules from RFC 9179):
/// - Strips a leading "the " prefix (case-insensitive)
/// - Converts [astronomicalBody] to lowercase
///
/// Validation (MUST rules):
/// - Rejects [alternateSystem] if feature flag is disabled
/// - Rejects [astronomicalBody] values containing characters outside
///   ASCII ranges 32–64 and 91–126
ReferenceFrameValidationResult validateReferenceFrame(
  ReferenceFrame frame, {
  required bool alternateSystemsFeatureEnabled,
}) {
  // Scenario 4: reject alternate-system when feature not enabled
  if (frame.alternateSystem != null && !alternateSystemsFeatureEnabled) {
    return ReferenceFrameValidationResult.invalid(
      frame: frame,
      error: 'feature-not-supported: alternate-system requires the alternate-systems feature',
    );
  }

  // Apply SHOULD normalizations before pattern check
  String body = frame.astronomicalBody;

  // Scenario 7: strip leading "the " prefix
  if (body.toLowerCase().startsWith('the ')) {
    body = body.substring(4);
  }

  // Scenario 6: normalize to lowercase
  body = body.toLowerCase();

  // Scenario 5: reject values with characters outside ASCII 32–64, 91–126
  if (!_asciiPattern.hasMatch(body)) {
    return ReferenceFrameValidationResult.invalid(
      frame: frame,
      error: 'pattern constraint violation: astronomical-body contains invalid characters',
    );
  }

  final normalized = ReferenceFrame(
    astronomicalBody: body,
    alternateSystem: frame.alternateSystem,
  );

  return ReferenceFrameValidationResult.valid(normalized);
}
