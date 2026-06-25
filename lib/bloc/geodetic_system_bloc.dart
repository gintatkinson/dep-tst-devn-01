import 'dart:async';
import 'package:app_flutter/domain/geodetic_system.dart';
import 'package:app_flutter/domain/geodetic_system_validation.dart';
import 'package:app_flutter/persistence/geodetic_system_adapter.dart';

sealed class GeodeticSystemState {
  const GeodeticSystemState();
}

final class GeodeticSystemInitial extends GeodeticSystemState {
  const GeodeticSystemInitial();
}

final class GeodeticSystemLoading extends GeodeticSystemState {
  const GeodeticSystemLoading();
}

final class GeodeticSystemLoaded extends GeodeticSystemState {
  final GeodeticSystem system;
  const GeodeticSystemLoaded(this.system);
}

final class GeodeticSystemError extends GeodeticSystemState {
  final String message;
  const GeodeticSystemError(this.message);
}

class GeodeticSystemBloc {
  final IGeodeticSystemRepository _repository;

  final _controller = StreamController<GeodeticSystemState>.broadcast();

  GeodeticSystemState _state = const GeodeticSystemInitial();

  GeodeticSystemBloc({required IGeodeticSystemRepository repository})
      : _repository = repository;

  GeodeticSystemState get state => _state;

  Stream<GeodeticSystemState> get stream => _controller.stream;

  void load(String nodeId) {
    _emit(const GeodeticSystemLoading());
    _repository.fetchGeodeticSystem(nodeId).then((system) {
      final resolved = system ?? const GeodeticSystem();
      final result = validateGeodeticSystem(resolved, isCartesian: false);
      _emit(GeodeticSystemLoaded(result.normalizedSystem));
    }).catchError((Object err) {
      _emit(GeodeticSystemError(err.toString()));
    });
  }

  Future<void> save(
    String nodeId,
    GeodeticSystem system, {
    bool isCartesian = false,
  }) async {
    final result = validateGeodeticSystem(
      system,
      isCartesian: isCartesian,
    );
    if (!result.isValid) {
      _emit(GeodeticSystemError(result.error!));
      return;
    }
    try {
      await _repository.saveGeodeticSystem(nodeId, result.normalizedSystem);
      _emit(GeodeticSystemLoaded(result.normalizedSystem));
    } catch (err) {
      _emit(GeodeticSystemError(err.toString()));
    }
  }

  void _emit(GeodeticSystemState newState) {
    _state = newState;
    if (!_controller.isClosed) {
      _controller.add(newState);
    }
  }

  void dispose() {
    if (!_controller.isClosed) {
      _controller.close();
    }
  }
}
