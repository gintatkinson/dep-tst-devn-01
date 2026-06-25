import 'dart:async';
import 'package:app_flutter/domain/reference_frame.dart';
import 'package:app_flutter/domain/reference_frame_validation.dart';
import 'package:app_flutter/persistence/reference_frame_adapter.dart';

/// @realizes UML::ReferenceFrame state machine
///
/// Sealed base class for all [ReferenceFrameBloc] states.
sealed class ReferenceFrameState {
  const ReferenceFrameState();
}

/// Initial state before any load or save has been dispatched.
final class ReferenceFrameInitial extends ReferenceFrameState {
  const ReferenceFrameInitial();
}

/// Emitted while a load operation is in progress.
final class ReferenceFrameLoading extends ReferenceFrameState {
  const ReferenceFrameLoading();
}

/// Emitted when the [ReferenceFrame] has been successfully loaded or saved.
final class ReferenceFrameLoaded extends ReferenceFrameState {
  final ReferenceFrame frame;
  const ReferenceFrameLoaded(this.frame);
}

/// Emitted when a validation or persistence error occurs.
final class ReferenceFrameError extends ReferenceFrameState {
  final String message;
  const ReferenceFrameError(this.message);
}

/// @realizes UML::ReferenceFrame::load, UML::ReferenceFrame::save
///
/// Stream-based BLoC managing [ReferenceFrame] load/save lifecycle.
/// Depends on [IReferenceFrameRepository] — never on a concrete adapter.
class ReferenceFrameBloc {
  final IReferenceFrameRepository _repository;

  final _controller = StreamController<ReferenceFrameState>.broadcast();

  ReferenceFrameState _state = const ReferenceFrameInitial();

  ReferenceFrameBloc({required IReferenceFrameRepository repository})
      : _repository = repository;

  /// Current synchronous state snapshot.
  ReferenceFrameState get state => _state;

  /// Stream of state transitions.
  Stream<ReferenceFrameState> get stream => _controller.stream;

  /// Loads the [ReferenceFrame] for [nodeId] from the repository.
  /// Returns the default frame ("earth") when no value is stored.
  void load(String nodeId) {
    _emit(const ReferenceFrameLoading());
    _repository.fetchReferenceFrame(nodeId).then((frame) {
      _emit(ReferenceFrameLoaded(frame ?? const ReferenceFrame()));
    }).catchError((Object err) {
      _emit(ReferenceFrameError(err.toString()));
    });
  }

  /// Validates and saves [frame] for [nodeId].
  /// Emits [ReferenceFrameError] on validation failure without persisting.
  Future<void> save(
    String nodeId,
    ReferenceFrame frame, {
    bool alternateSystemsFeatureEnabled = false,
  }) async {
    final result = validateReferenceFrame(
      frame,
      alternateSystemsFeatureEnabled: alternateSystemsFeatureEnabled,
    );
    if (!result.isValid) {
      _emit(ReferenceFrameError(result.error!));
      return;
    }
    try {
      await _repository.saveReferenceFrame(nodeId, result.normalizedFrame);
      _emit(ReferenceFrameLoaded(result.normalizedFrame));
    } catch (err) {
      _emit(ReferenceFrameError(err.toString()));
    }
  }

  void _emit(ReferenceFrameState newState) {
    _state = newState;
    if (!_controller.isClosed) {
      _controller.add(newState);
    }
  }

  /// Releases the stream controller. Call in [State.dispose] or [tearDown].
  void dispose() {
    _controller.close();
  }
}
