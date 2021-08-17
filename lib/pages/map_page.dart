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

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // reference to our single class that manages the functions
  final dbHelper = DatabaseHelper.instance;
  final fns = FnsHellper.instance;
  final services = FnsGeolacalizacion.instance;

  // CRONOMETRO
  bool _isStart = true;
  bool _isButtonDisabled = true;
  String _stopwatchText = '00:00:00';
  final _stopWatch = new Stopwatch();
  final _timeout = const Duration(seconds: 1);

  late final MapController _mapController = MapController();
  bool isLocation = false;
  var points = <LatLng>[];

  late StreamSubscription<Position> _positionStream;
  double lng = 0, lat = 0, lngInit = 0, latInit = 0;
  String _velocidad = "0", _distancia = "0";
  int _tiempo = 0;
  double velocidad = 0;
  String tiempo = "0";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getPosicionActual();
    _deletePointsAll();
    _getAllPoints();
  }

  @override
  void dispose() {
    _resetButtonPressed();
    FlutterBackgroundService().sendData(
      {"action": "stopService"},
    );
    super.dispose();
  }

  Future<void> _getPosicionActual() async {
    var posActual = await Geolocator.getCurrentPosition();
    setState(() {
      lngInit = posActual.longitude;
      latInit = posActual.latitude;
      isLocation = true;
    });
  }

  Widget _mapaHome() {
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

  Widget _panelHomeInfo() {
    return Positioned(
      top: 120.0,
      left: 30.0,
      right: 30.0,
      child: Container(
        child: Column(
          children: [
            StreamBuilder<Map<String, dynamic>?>(
              stream: FlutterBackgroundService().onDataReceived,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final data = snapshot.data!;

                _velocidad = data["velocidad"].toStringAsFixed(2);
                _distancia = data["distancia"].toStringAsFixed(2);

                _mapController.move(LatLng(data["lat"], data["lng"]), 17.0);
                points.add(LatLng(data["lat"], data["lng"]));

                return Text(data["velocidad"].toString());
              },
            ),
            Text(
                "Velocidad: ${_velocidad.toString()} | Tiempo: ${tiempo.toString()}"),
          ],
        ),
      ),
    );
  }

  Widget _itemCard(IconData icono, String texto1, String texto2) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
           color: Colors.purple,
           borderRadius: BorderRadius.circular(15.0)),
        child: Padding(
          padding: const EdgeInsets.only(
              top: 15.0, bottom: 15.0, left: 10.0, right: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icono,
                size: 40.0,
                color: Colors.white,
              ),
              SizedBox(
                width: 10.0,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    texto1,
                    style: TextStyle(
                      fontSize: 8.0,
                      color: Colors.white
                    ),
                  ),
                  Text(
                    texto2,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _Cronometro() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _stopwatchText,
              style: GoogleFonts.oswald(
                textStyle: TextStyle(
                    color: Colors.black87, fontSize: 65.0, letterSpacing: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _btnIniciar() {
    return MaterialButton(
      onPressed: () {
        _startStopButtonPressed();
        setState(() {});
      },
      color: Colors.purple,
      textColor: Colors.white,
      child: Icon(
        Icons.play_arrow,
        size: 48,
      ),
      padding: EdgeInsets.all(16),
      shape: CircleBorder(),
    );
  }

  Widget _btnPausa() {
    return MaterialButton(
      onPressed: () {
        !_isButtonDisabled ? _startStopButtonPressed() : null;
      },
      color: !_isButtonDisabled ? Colors.yellowAccent : Colors.black26,
      textColor: Colors.white,
      child: Icon(
        Icons.pause,
        size: 48,
      ),
      padding: EdgeInsets.all(16),
      shape: CircleBorder(),
    );
  }

  Widget _btnTest() {
    return GestureDetector(
      onTap: () {
        _startStopButtonPressed();
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.purple,
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 1,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
          child: Center(
              child: Text(
            "INICIAR",
            style: TextStyle(
                fontSize: 20.0,
                color: Colors.white,
                fontWeight: FontWeight.bold),
          )),
        ),
      ),
    );
  }

  Widget _btnStop() {
    return MaterialButton(
      onPressed: () {
        !_isButtonDisabled ? _resetButtonPressed() : null;
      },
      color: !_isButtonDisabled ? Colors.redAccent : Colors.black26,
      textColor: Colors.white,
      child: Icon(
        Icons.stop,
        size: 24,
      ),
      padding: EdgeInsets.all(16),
      shape: CircleBorder(),
    );
  }

  Widget _btnBloquear() {
    return MaterialButton(
      onPressed: () {
        if (_isButtonDisabled && !_isStart) {
          setState(() {
            _isButtonDisabled = false;
          });
        } else {
          setState(() {
            _isButtonDisabled = true;
          });
        }
      },
      color: Colors.black,
      textColor: Colors.white,
      child: Icon(
        Icons.lock,
        size: 24,
      ),
      padding: EdgeInsets.all(16),
      shape: CircleBorder(),
    );
  }

  Widget _btnsplash(){
    return Positioned(
      bottom: 60.0,
      left: 20.0,
      right: 20.0,
      child: GestureDetector(
        onTap: (){

        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.purple,
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(child: Text("Subir nueva marca", style: TextStyle(color: Colors.white, fontSize: 25.0),),),
          ),
        ),
      ),
    );
  }

  Widget _panelScrool() {
    return DraggableScrollableSheet(
      initialChildSize: 0.15,
      minChildSize: 0.15,
      maxChildSize: 0.35,
      builder: (BuildContext context, ScrollController scrollController) {
        return Padding(
          padding: const EdgeInsets.only( left: 8.0, right: 8.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Scrollbar(
              child: ListView.builder(
                controller: scrollController,
                itemCount: 1,
                itemBuilder: (BuildContext context, int index) {
                  return _panelControls();
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _panelControls() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _btnBloquear(),
              _isStart ? _btnIniciar() : _btnPausa(),
              _btnStop(),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _itemCard(Icons.social_distance, "Distancia",
                  "${_distancia.toString()} Km"),
              // SizedBox(width: 5.0,),
              // _itemCard(Icons.timer, "Tiempo", "${_tiempo.toString()} Seg"),
              SizedBox(
                width: 5.0,
              ),
              _itemCard(
                  Icons.speed, "Velocidad", "${_velocidad.toString()} Km/h"),
            ],
          ),
          SizedBox(height: 10.0,),
          _btnsplash(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _mapaHome(),
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: _Cronometro(),),
          _panelHomeInfo(),
          _panelScrool(),
        ],
      ),
    );
  }

  void _insert(String lat, String lng) async {
    // row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.columnLatitud: lat,
      DatabaseHelper.columnLongitud: lng
    };
    final id = await dbHelper.insert(row);
    // print('inserted row id: $id');
  }

  void _getDistanciaRecorrido() async {
    final allRows = await dbHelper.queryAllRows('trackers');

    double totalDistance = 0.0;

    // Calculating the total distance by adding the distance
    // between small segments
    for (int i = 0; i < allRows.length - 1; i++) {
      totalDistance += fns.coordinateDistance(
        allRows[i]["latitud"],
        allRows[i]["longitud"],
        allRows[i + 1]["latitud"],
        allRows[i + 1]["longitud"],
      );
    }

    // Storing the calculated total distance of the route
    setState(() {
      _distancia = totalDistance.toStringAsFixed(2);
      print('DISTANCE: $_distancia km');
    });

    print(allRows);

    //allRows.forEach((item) {
    //  setState(() {
    //    points.add(LatLng(double.parse(item["latitud"]), double.parse(item["longitud"])));
    //  });
    //});
  }

  void _getAllPoints() async {
    final allRows = await dbHelper.queryAllRows('trackers');
    print(allRows);

    //allRows.forEach((item) {
    //  setState(() {
    //    points.add(LatLng(double.parse(item["latitud"]), double.parse(item["longitud"])));
    //  });
    //});
  }

  void _update() async {
    // row to update
    Map<String, dynamic> row = {
      DatabaseHelper.columnId: 1,
      DatabaseHelper.columnLatitud: 'Mary',
      DatabaseHelper.columnLongitud: 32
    };
    final rowsAffected = await dbHelper.update(row);
    print('updated $rowsAffected row(s)');
  }

  void _delete() async {
    // Assuming that the number of rows is the id for the last row.
    final id = await dbHelper.queryRowCount();
    final rowsDeleted = await dbHelper.delete(id!);
    print('deleted $rowsDeleted row(s): row $id');
  }

  void _deletePointsAll() async {
    await dbHelper.deleteAllRows('trackers');
  }

  // FUNCIONES DE CRONOMETRO
  void _startTimeout() {
    new Timer(_timeout, _handleTimeout);
  }

  void _handleTimeout() {
    if (_stopWatch.isRunning) {
      _startTimeout();
    }
    setState(() {
      _setStopwatchText();
    });
  }

  void _startStopButtonPressed() {
    setState(() {
      if (_stopWatch.isRunning) {
        _isStart = true;
        _isButtonDisabled = true;
        _stopWatch.stop();
        FlutterBackgroundService().sendData(
          {"action": "stopService"},
        );
      } else {
        _isStart = false;
        _stopWatch.start();
        _startTimeout();
        // Inicializo el servicio en segundo plano
        FlutterBackgroundService.initialize(onStart);
      }
    });
  }

  void _resetButtonPressed() {
    if (_stopWatch.isRunning) {
      _startStopButtonPressed();
    }
    setState(() {
      _stopWatch.reset();
      _setStopwatchText();
    });
  }

  void _setStopwatchText() {
    _stopwatchText = _stopWatch.elapsed.inHours.toString().padLeft(2, '0') +
        ':' +
        (_stopWatch.elapsed.inMinutes % 60).toString().padLeft(2, '0') +
        ':' +
        (_stopWatch.elapsed.inSeconds % 60).toString().padLeft(2, '0');
  }
}

void onStart() {
  WidgetsFlutterBinding.ensureInitialized();
  final service = FlutterBackgroundService();
  final dbHelper = DatabaseHelper.instance;
  final fns = FnsHellper.instance;

  double lngS = 0, latS = 0, velocidadS = 0, distanciaS = 0;

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

    var position = await Geolocator.getCurrentPosition();
    double _speed = position.speed < 1
        ? 0
        : position.speed *
            3.5999971200023; //Converting position speed from m/s to km/hr

    // _speed = double.parse(_speed.toStringAsFixed(2));
    // velocidadS = position.speed;
    // lngS = position.longitude;
    // latS = position.latitude;

    print(position.speed);

    // if (_speed != 0) {
    Map<String, dynamic> row = {
      DatabaseHelper.columnLatitud: position.latitude.toString(),
      DatabaseHelper.columnLongitud: position.longitude.toString()
    };
    final id = await dbHelper.insert(row);

    double totalDistance = 0.0;
    final allRows = await dbHelper.queryAllRows('trackers');
    for (int i = 0; i < allRows.length - 1; i++) {
      totalDistance += fns.coordinateDistance(
        double.parse(allRows[i]["latitud"]),
        double.parse(allRows[i]["longitud"]),
        double.parse(allRows[i + 1]["latitud"]),
        double.parse(allRows[i + 1]["longitud"]),
      );
    }

    distanciaS = totalDistance;
    lngS = position.longitude;
    latS = position.latitude;
    velocidadS = position.speed;
    //}

    service.setNotificationInfo(
      title: "Pucela Runnning",
      content:
          "Duración: ${DateTime.now()} \t Distancia: $distanciaS  \t Velocidad: $velocidadS",
    );

    service.sendData(
      {
        "current_date": DateTime.now().toIso8601String(),
        "lat": latS,
        "lng": lngS,
        "velocidad": velocidadS,
        "distancia": distanciaS
      },
    );
  });
}
