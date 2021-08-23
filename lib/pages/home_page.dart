import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:fullscreen/fullscreen.dart';
import 'package:pucela_run/pages/map_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pucela_run/pages/splash_page.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import 'mapby_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  // Variables
  final LocalStorage storage = new LocalStorage('pucela_app');

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
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void deactivate() {
    print("Deactivate");
    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        print('appLifeCycleState inactive');
        break;
      case AppLifecycleState.resumed:
        print('appLifeCycleState resumed');
        break;
      case AppLifecycleState.paused:
        print('appLifeCycleState paused');
        break;
      case AppLifecycleState.detached:
        print('FRCA: appLifeCycleState detached');
        WidgetsFlutterBinding.ensureInitialized();
        FlutterBackgroundService().stopBackgroundService();
        break;
    }
  }

  void _getInit() {
    _displayname = storage.getItem('LS_USER_DISPLAY_NAME');
    _displayemail = storage.getItem('LS_USER_MAIL');
    _displaydistancia = storage.getItem('LS_DISTANCIA');
    _displaydia = storage.getItem('LS_DIA');
    _displaymarcacarrera = storage.getItem('LS_MARCA_CARRERA');
    _displaytipocarrera = storage.getItem('LS_TIPO_CARRERA');
    _displayiduser = storage.getItem('LS_USER_ID');
    _displayavatar = storage.getItem('LS_AVATAR');
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
                    setState(() {_displaymarcacarrera = storage.getItem('LS_MARCA_CARRERA');});
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

  void _Salir() {
    storage.clear();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => splashPage()),
    );
  }
}
