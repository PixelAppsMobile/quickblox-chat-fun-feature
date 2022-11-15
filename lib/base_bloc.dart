import 'package:flutter/services.dart';
import 'package:quickblox_polls_feature/data/device_repository.dart';
import 'package:rxdart/rxdart.dart';

abstract class BaseBloc<A> {
  void init();

  void setArgs(A args);

  void dispose();
}

class Bloc<E, S, A> implements BaseBloc<A> {
  final DeviceRepository _deviceRepository = DeviceRepository();

  PublishSubject<E>? _eventController;
  PublishSubject<S>? _stateController;

  Sink<E>? get events => _eventController;

  PublishSubject<S>? get states => _stateController;

  @override
  void init() async {
    _deviceRepository.subscribeConnectionStatus();
    _eventController = PublishSubject<E>();
    _stateController = PublishSubject<S>();

    _eventController?.listen(onReceiveEvent);
  }

  @override
  void setArgs(A args) {}

  @override
  void dispose() {
    _eventController?.close();
    _stateController?.close();
  }

  void onBackgroundMode() async {
    _deviceRepository.unsubscribeConnectionStatus();
  }

  void onForegroundMode() async {
    _deviceRepository.subscribeConnectionStatus();
  }

  void onReceiveEvent(E receivedEvent) {}

  String makeErrorMessage(PlatformException? e) {
    String message = e?.message ?? "";
    String code = e?.code ?? "";
    return "$code : $message";
  }
}
