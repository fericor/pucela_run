import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pucela_run/pages/map_page.dart';
import 'package:pucela_run/pages/test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'mapby_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variables
  String imgUser =
      "https://icons-for-free.com/iconfiles/png/512/avatar+human+male+man+men+people+person+profile+user+users-1320196163635839021.png";

  Widget _panelMainHome() {
    return Positioned(
      bottom: 100,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: () {}, icon: Icon(Icons.settings)),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapPage()),
              );
            },
            child: Container(
              width: 100,
              height: 100,
              child: Center(
                  child: Text(
                "INICIAR",
                style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              )),
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: Colors.purple),
            ),
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.music_note)),
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Container(
          height: 120.0,
          width: 120.0,
          child: FittedBox(
            child: FloatingActionButton(
                backgroundColor: Colors.purple,
                child: const Icon(Icons.play_arrow_outlined, size: 50.0,),
                onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapPage()),
              );
            }),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 400.0,
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/logoPucelaRun.png'),
                  fit: BoxFit.fitHeight,
                ),
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
                SizedBox(height: 60.0),
                _headerText(),
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

      // _panelMainHome(),
    );
  }

  // Widgets
  Widget _headerText() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Image.asset(
              'assets/logo_mini.png',
              width: 60.0,
            ),
            SizedBox(
              width: 10.0,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "PUCELA RUN",
                  style: GoogleFonts.oswald(
                    textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 25.0,
                        letterSpacing: 0.5),
                  ),
                ),
                Text(
                  "Carreras",
                  style: GoogleFonts.oswald(
                    textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
      top: 450.0,
      right: 0.0,
      left: 100.0,
      child: Container(
        width: MediaQuery.of(context).size.width - 100.0,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0),
              bottomLeft: Radius.circular(15.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        child: Text("5K", style: GoogleFonts.oswald(
                          textStyle: TextStyle(
                            color: Colors.white, fontSize: 40.0,),
                        ),),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Pucela Run",style: GoogleFonts.oswald(
                        textStyle: TextStyle(
                            color: Colors.white, fontSize: 20.0, letterSpacing: 0.5),
                      ),),
                      Text("Carrera Virtual",style: GoogleFonts.oswald(
                        textStyle: TextStyle(
                            color: Colors.white, fontSize: 15.0, letterSpacing: 0.5),
                      ),),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Icon(Icons.calendar_today, size: 30.0, color: Colors.white,),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("DATE", style: TextStyle(color: Colors.white60, fontWeight: FontWeight.bold, fontSize: 15.0),),
                          Text("Junio 21, 2021", style: TextStyle(color: Colors.white, fontSize: 13.0),),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Icon(Icons.location_on, size: 30.0, color: Colors.white,),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("UBICACIÓN", style: TextStyle(color: Colors.white60, fontWeight: FontWeight.bold, fontSize: 15.0),),
                          Text("Valladolid, ES", style: TextStyle(color: Colors.white, fontSize: 13.0),),
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

  // Funciones
  Widget _panelHeader() {
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Feed",
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 30.0),
          ),
          Container(
            height: 40.0,
            width: 40.0,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(imgUser),
                fit: BoxFit.fill,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _panelFondo() {
    return Positioned(
      top: 0.0,
      left: 0.0,
      right: 0.0,
      bottom: 0.0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/runner.png'),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardRunner() {
    return Padding(
      padding:
          const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 30.0, right: 30.0),
      child: Center(
        child: Card(
          child: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => mapByPage()),
              );
            },
            child: Column(
              children: [
                _cardRunnerHeader(),
                _cardRunnerBody(),
                Divider(
                  height: 20,
                  thickness: 2,
                  indent: 10,
                  endIndent: 10,
                ),
                _cardRunnerFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardRunnerHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Container(
            height: 40.0,
            width: 40.0,
            decoration: BoxDecoration(
              color: Colors.purple,
              image: DecorationImage(
                image: NetworkImage(imgUser),
                fit: BoxFit.fill,
              ),
            ),
          ),
          SizedBox(
            width: 10.0,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Felix Cortez Arevalo",
                style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "Running",
                style: TextStyle(fontSize: 15.0, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardRunnerBody() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.black12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Text("Distancia: "),
                      Text(
                        "15.50 km",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Text("Tiempo: "),
                      Text(
                        "120 seg",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Text("Velocidad: "),
                      Text(
                        "15km/h",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 10.0,
          ),
          Container(
            child: Image(
              image: AssetImage('assets/mapa.jpg'),
              height: 100.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardRunnerFooter() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.account_balance_sharp,
            size: 50.0,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Damian just complketed the chellange of"),
            Text(
              "Abril month cycling",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        )
      ],
    );
  }
}
