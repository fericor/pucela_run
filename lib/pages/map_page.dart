import 'dart:async';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:pucela_run/functions/database.dart';
import 'package:pucela_run/functions/geolocation.dart';
import 'package:pucela_run/functions/hellpers.dart';
import 'package:latlong2/latlong.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:localstorage/localstorage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:pucela_run/widgets/pulsacion_page.dart';
import 'package:fullscreen/fullscreen.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // reference to our single class that manages the functions
  final dbHelper = DatabaseHelper.instance;
  final fns = FnsHellper.instance;
  final services = FnsGeolacalizacion.instance;
  final LocalStorage storage = new LocalStorage('pucela_app');

  // VARIABLES GLOBALES

  // CRONOMETRO
  bool _isStart = true;
  bool _isButtonDisabled = true;
  bool _isHidenPanel = true;
  bool _isTerminoRecorrido = false;
  bool _isPulsacion = false;
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

  // VARIABLES GLOBALES
  String _displayname = "PUCELA RUN";
  String _displayemail = "Carreras";
  String _displaydistancia = "0K";
  String _displaydia = "Junio 21, 2021";
  String _displaymarcacarrera = "0.00";
  String _displaytipocarrera = "Carrera Virtual";
  String _displayiduser = "0";
  String _displayavatar = "assets/logo_mini.png";
  String _displayubicacion = "Valladolid";

  @override
  void initState() {
    _getInit();
    _getPosicionActual();
    // _deletePointsAll();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _resetButtonPressed();
    FlutterBackgroundService().sendData(
      {"action": "stopService"},
    );
    super.dispose();
  }

  Future<void> _getInit() async {
    _displayname = storage.getItem('LS_USER_DISPLAY_NAME');
    _displayemail = storage.getItem('LS_USER_MAIL');
    _displaydistancia = storage.getItem('LS_DISTANCIA');
    _displaydia = storage.getItem('LS_DIA');
    _displaymarcacarrera = storage.getItem('LS_MARCA_CARRERA');
    _displaytipocarrera = storage.getItem('LS_TIPO_CARRERA');
    _displayiduser = storage.getItem('LS_USER_ID');
    _displayavatar = storage.getItem('LS_AVATAR');
  }

  _setMarcaTime() async {
    var url = Uri.parse('https://pucelarun.es/wp-admin/admin-ajax.php');
    var response = await http.post(url, body: {
      'action': 'upload_time',
      'id': _displayiduser,
      'timeStamp': _stopwatchText, // _stopwatchText, // DateTime.now(),
      'completed': _isTerminoRecorrido.toString(),
      'distance': _distancia.toString(),
      'distanceRun': '2000',
      'coordinates': points.toString()
    });

    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
      setState(() {
        storage.setItem('LS_MARCA_CARRERA', _stopwatchText);
      });
    } else {}
  }

  Future<void> _getPosicionActual() async {
    var posActual = await Geolocator.getCurrentPosition();
    setState(() {
      lngInit = posActual.longitude;
      latInit = posActual.latitude;

      lng = posActual.longitude;
      lat = posActual.latitude;
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
                          color: Colors.purple,
                          size: 45.0,
                        ),
                      ),
                    ),
                  ],
                ),
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
                    child: Text(""),
                  );
                }

                final data = snapshot.data!;

                _velocidad = data["velocidad"] == 0
                    ? "0.0"
                    : data["velocidad"].toStringAsFixed(2);
                _distancia = data["distancia"] == 0
                    ? "0.0"
                    : data["distancia"].toStringAsFixed(2);
                lat = data["lat"] == 0 ? latInit : data["lat"];
                lng = data["lng"] == 0 ? lngInit : data["lng"];

                if (data["lat"] != 0) {
                  _mapController.move(LatLng(data["lat"], data["lng"]), 17.0);
                  // points.add(LatLng(data["lat"], data["lng"]));

                  // points.clear();
                  if (data["route"] != null) {
                    data["route"].forEach((item) {
                      points.add(LatLng(double.parse(item["latitud"]),
                          double.parse(item["longitud"])));
                    });
                  } else {
                    points.add(LatLng(data["lat"], data["lng"]));
                  }
                }

                // Comprovamos Que ya ha termninado la carrera
                switch (_displaydistancia) {
                  case "2K":
                    {
                      if (double.parse(_distancia) >= 2.0) {
                        _startStopButtonPressed();
                        // Fluttertoast.showToast(
                        //    msg: "Ha terminado tu recorrido.",
                        //    toastLength: Toast.LENGTH_LONG,
                        //    gravity: ToastGravity.TOP,
                        //    timeInSecForIosWeb: 1,
                        //    backgroundColor: Colors.red,
                        //    textColor: Colors.white,
                        //    fontSize: 26.0
                        // );
                      }
                    }
                    break;

                  case "5K":
                    {
                      if (double.parse(_distancia) >= 5.0) {
                        _startStopButtonPressed();
                        // Fluttertoast.showToast(
                        //     msg: "Ha terminado tu recorrido.",
                        //     toastLength: Toast.LENGTH_LONG,
                        //     gravity: ToastGravity.TOP,
                        //     timeInSecForIosWeb: 1,
                        //     backgroundColor: Colors.red,
                        //     textColor: Colors.white,
                        //     fontSize: 26.0
                        // );
                      }
                    }
                    break;

                  case "10K":
                    {
                      if (double.parse(_distancia) >= 10.0) {
                        _startStopButtonPressed();
                        // Fluttertoast.showToast(
                        //     msg: "Ha terminado tu recorrido.",
                        //     toastLength: Toast.LENGTH_LONG,
                        //     gravity: ToastGravity.TOP,
                        //     timeInSecForIosWeb: 1,
                        //     backgroundColor: Colors.red,
                        //     textColor: Colors.white,
                        //     fontSize: 26.0
                        // );
                      }
                    }
                    break;
                }

                return Text(""); // data["vFinal"].toString()
              },
            ),
            // Text("Velocidad: ${_velocidad.toString()} | Lat: ${lat.toString()}"),
          ],
        ),
      ),
    );
  }

  Widget _itemCard(IconData icono, String texto1, String texto2) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            color: Colors.purple, borderRadius: BorderRadius.circular(15.0)),
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
                    style: TextStyle(fontSize: 8.0, color: Colors.white),
                  ),
                  Text(
                    texto2,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: InkWell(
              onTap: () {
                Widget cancelButton1 = FlatButton(
                  child: Text("Cancelar"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                );
                Widget continueButton1 = FlatButton(
                  child: Text("Continuar"),
                  onPressed: () {
                    !_isButtonDisabled ? _resetButtonPressed() : null;
                    Navigator.of(context).pop();
                    Navigator.pop(context);
                  },
                );

                AlertDialog alert1 = AlertDialog(
                  title: Text("¿Estás seguro de que quieres pararlo?"),
                  content:
                  Text("Si paras el recorrido tendrás que empezarlo de nuevo."),
                  actions: [
                    cancelButton1,
                    continueButton1,
                  ],
                );

                if (_stopWatch.isRunning) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return alert1;
                    },
                  );
                }else{
                  Navigator.pop(context, true);
                }

              },
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.arrow_back,
                  size: 30.0,
                  color: Colors.purple,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Center(
              child: Text(
                _stopwatchText,
                style: GoogleFonts.oswald(
                  textStyle: TextStyle(
                      color: Colors.black87,
                      fontSize: 45.0,
                      letterSpacing: 0.5),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: InkWell(
              onTap: () async {
                var posActual = await Geolocator.getCurrentPosition();
                isLocation = false;
                _mapController.move(LatLng(latInit, lngInit), 17.0);
                setState(() {
                  isLocation = true;
                });
              },
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.my_location,
                  size: 30.0,
                  color: Colors.purple,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _btnIniciar() {
    return MaterialButton(
      onPressed: () {
        if(!_isButtonDisabled){
          setState(() {
            _isPulsacion = false;
          });
        }else{
          setState(() {
            _isPulsacion = true;
          });
        }

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

  Widget _btnStop() {
    return MaterialButton(
      onPressed: () {
        Widget cancelButton = FlatButton(
          child: Text("Cancelar"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        );
        Widget continueButton = FlatButton(
          child: Text("Continuar"),
          onPressed: () {
            !_isButtonDisabled ? _resetButtonPressed() : null;
            Navigator.of(context).pop();
            _setMarcaTime();
          },
        );

        AlertDialog alert = AlertDialog(
          title: Text("¿Estás seguro de que quieres pararlo?"),
          content:
              Text("Si paras el recorrido tendrás que empezarlo de nuevo."),
          actions: [
            cancelButton,
            continueButton,
          ],
        );

        if (!_isButtonDisabled) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return alert;
            },
          );
        }
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
        (_isButtonDisabled && !_isStart) ? Icons.lock : Icons.lock_open,
        size: 24,
      ),
      padding: EdgeInsets.all(16),
      shape: CircleBorder(),
    );
  }

  Widget _btnsplash() {
    return GestureDetector(
      onTap: () {
        Widget cancelButton = FlatButton(
          child: Text("Cancelar"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        );
        Widget continueKOButton = FlatButton(
          child: Text("Continuar"),
          onPressed: () {
            if (_isButtonDisabled) {
              _setMarcaTime();
              _resetButtonPressed();

              setState(() {
                _isTerminoRecorrido = false;
              });
            }

            Fluttertoast.showToast(
                msg: "Información guardada con exito.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
            Navigator.of(context).pop();
          },
        );
        Widget continueOKButton = FlatButton(
          child: Text("Continuar"),
          onPressed: () {
            if (_isButtonDisabled) {
              _setMarcaTime();
              _resetButtonPressed();

              setState(() {
                _isTerminoRecorrido = true;
              });
            }

            Fluttertoast.showToast(
                msg: "Información guardada con exito.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
            Navigator.of(context).pop();
          },
        );

        switch (_displaydistancia) {
          case "2K":
            {
              print(_distancia);
              if (double.parse(_distancia) < 2.0) {
                AlertDialog alert = AlertDialog(
                  title: Text("No has terminado el recorrido"),
                  content: Text(
                      "Si lo subes tu recorrido se marcará como no terminado. ¿Estás seguro de que quieres publicarla?"),
                  actions: [
                    cancelButton,
                    continueKOButton,
                  ],
                );
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return alert;
                  },
                );
              } else {
                AlertDialog alert = AlertDialog(
                  title: Text("Recorrido terminado"),
                  content: Text("Se enviara la información al servidor."),
                  actions: [
                    cancelButton,
                    continueOKButton,
                  ],
                );
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return alert;
                  },
                );
              }
            }
            break;

          case "5K":
            {
              print("Good");
            }
            break;

          case "10K":
            {
              print("Fair");
            }
            break;

          default:
            {
              print("Invalid choice");
            }
            break;
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.purple,
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: Text(
              "Subir nueva marca",
              style: TextStyle(color: Colors.white, fontSize: 25.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _panelScrool(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.18,
      maxChildSize: 0.35,
      builder: (context, scrollController) {
        return Container(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: IconButton(
                      icon: Icon(
                        _isHidenPanel
                            ? Icons.arrow_circle_down_rounded
                            : Icons.arrow_circle_up_rounded,
                        size: 30.0,
                      ),
                      onPressed: () {
                        if (_isHidenPanel) {
                          scrollController.jumpTo(-190);
                          scrollController.animateTo(20,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.bounceIn);
                          setState(() {
                            _isHidenPanel = false;
                          });
                        } else {
                          scrollController.jumpTo(0);
                          scrollController.animateTo(20,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.bounceOut);
                          setState(() {
                            _isHidenPanel = true;
                          });
                        }
                      },
                    ),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: _panelControls(),
                ),
              ],
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
          SizedBox(
            height: 10.0,
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _btnBloquear(),
                _isStart ? _btnIniciar() : _btnPausa(),
                _btnStop(),
              ],
            ),
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
          SizedBox(
            height: 10.0,
          ),
          _btnsplash(),
          SizedBox(
            height: 10.0,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    FullScreen.enterFullScreen(FullScreenMode.EMERSIVE_STICKY);
    return Scaffold(
      body: Stack(
        children: [
          _mapaHome(),
          Positioned(
            top: 20.0,
            left: 0.0,
            right: 0.0,
            child: _Cronometro(),
          ),
          _panelHomeInfo(),
          _panelScrool(context),
          _isPulsacion ? TimerCountDownWidget(
            onTimerFinish: () {
              _startStopButtonPressed();
              setState(() {
                _isPulsacion = false;
              });
            },
          ) : Text("")
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

  void _update() async {
    // row to update
    Map<String, dynamic> row = {
      DatabaseHelper.columnId: 1,
      DatabaseHelper.columnLatitud: 1,
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

Future<void> onStart() async {
  WidgetsFlutterBinding.ensureInitialized();
  final service = FlutterBackgroundService();
  final dbHelper = DatabaseHelper.instance;
  final fns = FnsHellper.instance;

  double lngS = 0, latS = 0, distanciaS = 0, totalDistance = 0, velocidadS = 0;
  var allRows = null;

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

  bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();

  Geolocator.getPositionStream().listen((Position position) async {
    double _speed = position.speed < 0.5
        ? 0
        : position.speed * 3.6; //Converting position speed from m/s to km/hr

    if (_speed != 0) {
      final allRows = await dbHelper.queryAllRows('trackers');

      double totalDistance = 0;
      for (int i = 0; i < allRows.length - 1; i++) {
        totalDistance += fns.coordinateDistance(
          double.parse(allRows[i]["latitud"]),
          double.parse(allRows[i]["longitud"]),
          double.parse(allRows[i + 1]["latitud"]),
          double.parse(allRows[i + 1]["longitud"]),
        );
      }

      Map<String, dynamic> row = {
        DatabaseHelper.columnLatitud: position.latitude.toString(),
        DatabaseHelper.columnLongitud: position.longitude.toString(),
        DatabaseHelper.columnDistancia: totalDistance.toString(),
        DatabaseHelper.columnVelocidad: _speed.toString(),
      };
      final id = await dbHelper.insert(row);

      distanciaS = totalDistance;
      lngS = position.longitude;
      latS = position.latitude;
      velocidadS = _speed; // position.speed;
    }

    service.setNotificationInfo(
      title: "Pucela Runnning",
      content:
          "Duración: ${DateTime.now()} \t Lat: ${position.latitude} \t Lng: ${position.longitude} \t Distancia: $distanciaS  \t Velocidad: $velocidadS",
    );

    service.sendData(
      {
        "current_date": DateTime.now().toIso8601String(),
        "lat": latS,
        "lng": lngS,
        "velocidad": velocidadS,
        "distancia": distanciaS,
        "vFinal": position.speed,
        "route": allRows
      },
    );
  });
}
