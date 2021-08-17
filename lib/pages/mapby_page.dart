import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:pucela_run/functions/database.dart';
import 'package:pucela_run/functions/geolocation.dart';
import 'package:pucela_run/functions/hellpers.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class mapByPage extends StatefulWidget {
  const mapByPage({Key? key}) : super(key: key);

  @override
  _mapByPageState createState() => _mapByPageState();
}

class _mapByPageState extends State<mapByPage> {

  final dbHelper = DatabaseHelper.instance;

  late final MapController _mapController = MapController();
  double lng = 0, lat = 0, lngInit = 0, latInit = 0;
  bool isLocation = false;
  var points = <LatLng>[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getPosicionActual();
    _getDrawerTrayecto();
  }

  // Servicios
  Future<void> _getPosicionActual() async {
    var posActual = await Geolocator.getCurrentPosition();
    setState(() {
      lngInit = posActual.longitude;
      latInit = posActual.latitude;
      isLocation = true;
    });
  }

  void _getDrawerTrayecto() async {
    final allRows = await dbHelper.queryAllRows('trackers');

    allRows.forEach((item) {
      setState(() {
        points.add(LatLng(double.parse(item["latitud"]), double.parse(item["longitud"])));
      });
    });

    print(allRows);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _panelMap(),
      ],
    );
  }

  Widget _panelMap(){
    return Positioned(
      top: 0.0,
      left: 0.0,
      right: 0.0,
      bottom: 0.0,
      child: isLocation
          ? FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: LatLng(latInit, lngInit),
          zoom: 17.0,
        ),
        layers: [
          TileLayerOptions(
            // urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              urlTemplate:
              "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiZmVyaWNvciIsImEiOiJja3J3ZHpzNnQwZm54Mm5xamo0OHN6bDBhIn0.2EtgIWzOEgy6AKorHcL44w",
              subdomains: ['a', 'b', 'c']),
          MarkerLayerOptions(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(latInit, lngInit),
                builder: (ctx) => Container(
                  child: Icon(
                    Icons.my_location,
                    color: Colors.black,
                  ),
                ),
              ),
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(lat, lng),
                builder: (ctx) => Container(
                  child: Icon(
                    Icons.location_on,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ],
          ),
          PolylineLayerOptions(polylines: [
            Polyline(
              points: points,
              strokeWidth: 5.0,
              gradientColors: [
                Color(0xffE40203),
                Color(0xffFEED00),
                Color(0xff007E2D),
              ],
            )
          ]),
          CircleLayerOptions(circles: [
            CircleMarker(
              point: LatLng(latInit, lngInit),
              color: Colors.blue.withOpacity(0.7),
              borderStrokeWidth: 2,
              useRadiusInMeter: true,
              radius: 20, // 2000 meters | 2 km
            )
          ]),
        ],
      )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
