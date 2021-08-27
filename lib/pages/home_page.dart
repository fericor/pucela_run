import 'package:flutter/material.dart';
import 'package:pucela_run/pages/test2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fullscreen/fullscreen.dart';
import 'package:pucela_run/pages/map_page.dart';
import 'package:background_location/background_location.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pucela_run/pages/splash_page.dart';

import 'mapby_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variables
  late SharedPreferences sharedPreferences;

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
    _initServicio();
    // TODO: implement initState
    super.initState();
  }

  @override
  void deactivate() {
    print("Deactivate");
    super.deactivate();
  }

  @override
  void dispose() {
    BackgroundLocation.stopLocationService();
    super.dispose();
  }

  _getInit() async {
    sharedPreferences = await SharedPreferences.getInstance();

    setState(() {
      _displayname = sharedPreferences.getString('LS_USER_DISPLAY_NAME')!;
      _displayemail = sharedPreferences.getString('LS_USER_MAIL')!;
      _displaydistancia = sharedPreferences.getString('LS_DISTANCIA')!;
      _displaydia = sharedPreferences.getString('LS_DIA')!;
      _displaymarcacarrera = sharedPreferences.getString('LS_MARCA_CARRERA')!;
      _displaytipocarrera = sharedPreferences.getString('LS_TIPO_CARRERA')!;
      _displayiduser = sharedPreferences.getString('LS_USER_ID')!;
      _displayavatar = sharedPreferences.getString('LS_AVATAR')!;
    });
  }

  _initServicio() async {
    await BackgroundLocation.setAndroidNotification(
      title: 'Pucela Run',
      message: "Duración: Tracker de Geolocalizacion.",
      icon: '@mipmap/ic_launcher',
    );

    // await BackgroundLocation.setAndroidConfiguration(3000);
    await BackgroundLocation.startLocationService(distanceFilter: 10);
    BackgroundLocation.getLocationUpdates((location) {
      sharedPreferences.setString('LS_LAT_INIT', location.latitude.toString());
      sharedPreferences.setString('LS_LNG_INIT', location.longitude.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    FullScreen.enterFullScreen(FullScreenMode.EMERSIVE_STICKY);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Container(
          height: 120.0,
          width: 120.0,
          child: FittedBox(
            child: FloatingActionButton(
                backgroundColor: Colors.black87,
                child: const Icon(
                  Icons.play_arrow_outlined,
                  size: 50.0,
                ),
                onPressed: () async {
                  final reLoadPage = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MapPage()),
                  );

                  if (reLoadPage) {
                    setState(() {
                      _displaymarcacarrera =
                          sharedPreferences.getString('LS_MARCA_CARRERA')!;
                    });
                  }
                }),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0.0,
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.purple,
                    Colors.purpleAccent,
                  ],
                ),
                /*image: DecorationImage(
                  image: AssetImage('assets/bg_logo.png'),
                  fit: BoxFit.cover,
                ),*/
              ),
            ),
          ),
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.0),
                _headerText(),
                SizedBox(height: 20.0),
                Container(
                  height: 220.0,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _panelItemsHome(
                          'assets/bg.jpg', 'Carrera Presencial', 'De 9h a 13h'),
                      _panelItemsHome('assets/carrera_virtual.jpg',
                          'Carrera Virtual', 'De 9h a 13h'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _panelIfoUser(),
        ],
      ),
    );
  }

  // Widgets
  Widget _headerText() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, top: 5.0, bottom: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0, bottom: 10.0),
                child: Image.asset(
                  'assets/logo_mini.png',
                  width: 60.0,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              width: 10.0,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _displayname,
                    style: GoogleFonts.oswald(
                      textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          letterSpacing: 0.5),
                    ),
                  ),
                  Text(
                    _displayemail,
                    style: GoogleFonts.oswald(
                      textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 13.0,
                          letterSpacing: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            _simpleMenuPopup(),
          ],
        ),
      ),
    );
  }

  Widget _simpleMenuPopup() {
    return PopupMenuButton(
      icon: Icon(
        Icons.menu,
        size: 30.0,
        color: Colors.white,
      ),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: 'test2',
            child: Text('BBBBBB'),
          ),
          PopupMenuItem(
            value: 'test',
            child: Text('Service'),
          ),
          PopupMenuItem(
            value: 'mapById',
            child: Text('Test'),
          ),
          PopupMenuItem(
            value: 'Salir',
            child: Text('Salir'),
          )
        ];
      },
      onSelected: (String value) {
        if (value == "mapById") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => mapByPage()),
          );
        } else if (value == "test2") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyApp2()),
          );
        } else if (value == "test") {
        } else {
          _Salir();
        }
      },
    );
  }

  Widget _panelItemsHome(String imagen, text1, text2) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        child: Container(
          width: MediaQuery.of(context).size.width - 120.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
            image: DecorationImage(
              image: AssetImage(imagen),
              fit: BoxFit.fill,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: 10.0,
                left: 0.0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(color: Colors.black87),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text1,
                          style: GoogleFonts.oswald(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(text2),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _panelIfoUser() {
    return Positioned(
      top: 400.0,
      right: 0.0,
      left: 20.0,
      child: Container(
        width: MediaQuery.of(context).size.width - 100.0,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0),
            bottomLeft: Radius.circular(15.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.purple,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 10.0),
                            child: Text(
                              _displaydistancia != ""
                                  ? _displaydistancia
                                  : "NS",
                              style: GoogleFonts.oswald(
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 40.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pucela Run",
                            style: GoogleFonts.oswald(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  letterSpacing: 0.5),
                            ),
                          ),
                          Text(
                            _displaytipocarrera,
                            style: GoogleFonts.oswald(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.0,
                                  letterSpacing: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Última Marca",
                              style: GoogleFonts.oswald(
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.0,
                                ),
                              ),
                            ),
                            Text(
                              _displaymarcacarrera == ""
                                  ? "00:00:00"
                                  : "$_displaymarcacarrera",
                              style: GoogleFonts.oswald(
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Icon(
                          Icons.calendar_today,
                          size: 30.0,
                          color: Colors.white,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Fecha",
                            style: TextStyle(
                                color: Colors.white60,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.0),
                          ),
                          Text(
                            _displaydia != "" ? _displaydia : "Sin asignar",
                            style:
                                TextStyle(color: Colors.white, fontSize: 13.0),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Icon(
                          Icons.location_on,
                          size: 30.0,
                          color: Colors.white,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "UBICACIÓN",
                            style: TextStyle(
                                color: Colors.white60,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.0),
                          ),
                          Text(
                            "$_displayubicacion, ES",
                            style:
                                TextStyle(color: Colors.white, fontSize: 13.0),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _Salir() async {
    await sharedPreferences.clear();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => splashPage()),
    );
  }
}
