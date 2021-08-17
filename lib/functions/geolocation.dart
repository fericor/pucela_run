import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class FnsGeolacalizacion {

  // make this a singleton class
  FnsGeolacalizacion._privateConstructor();
  static final FnsGeolacalizacion instance = FnsGeolacalizacion._privateConstructor();

  // CRONOMETRO
  bool _isStart = true;
  bool _isButtonDisabled = true;
  String _stopwatchText = '00:00:00';
  final _stopWatch = new Stopwatch();
  final _timeout = const Duration(seconds: 1);


  onGeolocalizacion() {
    WidgetsFlutterBinding.ensureInitialized();
    final service = FlutterBackgroundService();
    service.onDataReceived.listen((event) {
      if (event!["action"] == "setAsForeground") {
        service.setForegroundMode(true);
        return;
      }

      if (event["action"] == "setAsBackground") {
        service.setForegroundMode(false);
      }

      if (event["action"] == "stopService") {
        service.stopBackgroundService();
      }
    });

    // bring to foreground
    service.setForegroundMode(true);

    Timer.periodic(Duration(seconds: 1), (timer) async {
      if (!(await service.isServiceRunning())) timer.cancel();

      var posActual = await Geolocator.getCurrentPosition();

      String lng = posActual.longitude.toString();
      String lat = posActual.latitude.toString();

      service.setNotificationInfo(
        title: "Pucela Run",
        content: "Updated at ${DateTime.now()} Lat: $lat Lng: $lng",
      );

      service.sendData(
        {"current_date": _stopwatchText},
      );
    });
  }

  // FUNCIONES DE CRONOMETRO
  startTimeout() {
    new Timer(_timeout, handleTimeout);
  }

  handleTimeout() {
    if (_stopWatch.isRunning) {
      startTimeout();
    }

    setStopwatchText();
  }

  startStopButtonPressed() {

      if (_stopWatch.isRunning) {
        _isStart = true;
        _isButtonDisabled = true;
        _stopWatch.stop();
      } else {
        _isStart = false;
        _stopWatch.start();
        startTimeout();
      }
  }

  resetButtonPressed() {
    if (_stopWatch.isRunning) {
      startStopButtonPressed();
    }

    _stopWatch.reset();
    setStopwatchText();
  }

  setStopwatchText() {
    _stopwatchText = _stopWatch.elapsed.inHours.toString().padLeft(2, '0') +
        ':' +
        (_stopWatch.elapsed.inMinutes % 60).toString().padLeft(2, '0') +
        ':' +
        (_stopWatch.elapsed.inSeconds % 60).toString().padLeft(2, '0');
  }

}