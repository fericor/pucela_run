import 'package:maps_toolkit/maps_toolkit.dart';
import 'dart:math' show cos, sqrt, asin;

class FnsHellper{

  // make this a singleton class
  FnsHellper._privateConstructor();
  static final FnsHellper instance = FnsHellper._privateConstructor();

  double? getDistancePoints(double lat1, lng1, lat2, lng2){
    final pointUno = LatLng(lat1, lng1);
    final pointDos  = LatLng(lat2, lng2);

    final distance = SphericalUtil.computeDistanceBetween(pointUno, pointDos) / 1000.0;

    return double.parse(distance.toStringAsFixed(2));
  }

  // ESTO RETORNA EL ESPACIO EN METROS
  double getEspacio(double velocidad, tiempo){
    final espacio = velocidad * tiempo;

    return double.parse(espacio.toStringAsFixed(2));
  }

  double coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }


}