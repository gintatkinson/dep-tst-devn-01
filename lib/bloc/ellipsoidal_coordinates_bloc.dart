import 'dart:async';
import 'package:app_flutter/domain/ellipsoidal_coordinates.dart';
import 'package:app_flutter/domain/ellipsoidal_coordinates_validation.dart';
import 'package:app_flutter/persistence/ellipsoidal_coordinates_adapter.dart';

sealed class EllipsoidalCoordinatesState {
  const EllipsoidalCoordinatesState();
}

final class EllipsoidalCoordinatesInitial extends EllipsoidalCoordinatesState {
  const EllipsoidalCoordinatesInitial();
}

final class EllipsoidalCoordinatesLoading extends EllipsoidalCoordinatesState {
  const EllipsoidalCoordinatesLoading();
}

final class EllipsoidalCoordinatesLoaded extends EllipsoidalCoordinatesState {
  final EllipsoidalCoordinates coordinates;
  const EllipsoidalCoordinatesLoaded(this.coordinates);
}

final class EllipsoidalCoordinatesError extends EllipsoidalCoordinatesState {
  final String message;
  const EllipsoidalCoordinatesError(this.message);
}

class EllipsoidalCoordinatesBloc {
  final IEllipsoidalCoordinatesRepository _repository;
  final _controller = StreamController<EllipsoidalCoordinatesState>.broadcast();
  EllipsoidalCoordinatesState _state = const EllipsoidalCoordinatesInitial();

  EllipsoidalCoordinatesBloc({required IEllipsoidalCoordinatesRepository repository})
      : _repository = repository;

  EllipsoidalCoordinatesState get state => _state;
  Stream<EllipsoidalCoordinatesState> get stream => _controller.stream;

  void load(String nodeId) {
    _emit(const EllipsoidalCoordinatesLoading());
    _repository.fetchEllipsoidalCoordinates(nodeId).then((coords) {
      _emit(EllipsoidalCoordinatesLoaded(coords ?? const EllipsoidalCoordinates()));
    }).catchError((Object err) {
      _emit(EllipsoidalCoordinatesError(err.toString()));
    });
  }

  Future<void> save(String nodeId, EllipsoidalCoordinates coords) async {
    _emit(const EllipsoidalCoordinatesLoading());
    final result = validateEllipsoidalCoordinates(coords);
    if (!result.isValid) {
      _emit(EllipsoidalCoordinatesError(result.error!));
      return;
    }
    try {
      await _repository.saveEllipsoidalCoordinates(nodeId, coords);
      _emit(EllipsoidalCoordinatesLoaded(coords));
    } catch (err) {
      _emit(EllipsoidalCoordinatesError(err.toString()));
    }
  }

  void _emit(EllipsoidalCoordinatesState newState) {
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
