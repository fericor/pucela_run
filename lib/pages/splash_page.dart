import 'dart:async';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';

class splashPage extends StatefulWidget {
  const splashPage({Key? key}) : super(key: key);

  @override
  _splashPageState createState() => _splashPageState();
}

class _splashPageState extends State<splashPage> {
  late bool _isLogin = false;
  late bool _passwordVisible = false;
  late SharedPreferences sharedPreferences;
  final TextEditingController _usuario = TextEditingController();
  final TextEditingController _contrasena = TextEditingController();

  @override
  void initState() {
    _isServiceLogin();
    // TODO: implement initState
    super.initState();
  }

  Future<void> _isServiceLogin() async {
    setState(() {
      _isLogin = true;
    });

    sharedPreferences = await SharedPreferences.getInstance();

    try {
      if (sharedPreferences.getString('LS_USER_PASS') != null ||
          sharedPreferences.getString('LS_USER_PASS') != "") {
        var url = Uri.https('pucelarun.es', '/wp-json/jwt-auth/v1/token', {
          'username': sharedPreferences.getString('LS_USER_USER'),
          'password': sharedPreferences.getString('LS_USER_PASS')
        });

        var response = await http.post(url);
        if (response.statusCode == 200) {
          var jsonResponse =
              convert.jsonDecode(response.body) as Map<String, dynamic>;
          String? userInit = sharedPreferences.getString("LS_USER_USER");
          String? passInit = sharedPreferences.getString("LS_USER_PASS");

          sharedPreferences.setString('LS_TOKEN', jsonResponse['token']);
          sharedPreferences.setString(
              'LS_USER_MAIL', jsonResponse['user_email']);
          sharedPreferences.setString(
              'LS_USER_NICENAME', jsonResponse['user_nicename']);
          sharedPreferences.setString(
              'LS_USER_DISPLAY_NAME', jsonResponse['user_display_name']);
          sharedPreferences.setString('LS_AVATAR', jsonResponse['avatar']);
          sharedPreferences.setString(
              'LS_DISTANCIA', jsonResponse['distancia']);
          sharedPreferences.setString('LS_DIA', jsonResponse['dia']);
          // sharedPreferences.setString('LS_MARCA_CARRERA', jsonResponse['marca_carrera']);
          sharedPreferences.setString(
              'LS_TIPO_CARRERA', jsonResponse['tipo_carrera']);
          sharedPreferences.setString(
              'LS_USER_ID', jsonResponse['user_id'].toString());

          sharedPreferences.setString('LS_USER_USER', userInit!);
          sharedPreferences.setString('LS_USER_PASS', passInit!);

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          setState(() {
            _isLogin = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLogin = false;
      });
    }
  }

  void getLogin(String user, pass, BuildContext context) async {
    sharedPreferences = await SharedPreferences.getInstance();

    var url = Uri.https('pucelarun.es', '/wp-json/jwt-auth/v1/token',
        {'username': user, 'password': pass});

    var response = await http.post(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;

      sharedPreferences.setString('LS_TOKEN', jsonResponse['token'].toString());
      sharedPreferences.setString(
          'LS_USER_MAIL', jsonResponse['user_email'].toString());
      sharedPreferences.setString(
          'LS_USER_NICENAME', jsonResponse['user_nicename'].toString());
      sharedPreferences.setString(
          'LS_USER_DISPLAY_NAME', jsonResponse['user_display_name'].toString());
      sharedPreferences.setString(
          'LS_AVATAR', jsonResponse['avatar'].toString());
      sharedPreferences.setString(
          'LS_DISTANCIA', jsonResponse['distancia'].toString());
      sharedPreferences.setString('LS_DIA', jsonResponse['dia'].toString());
      sharedPreferences.setString(
          'LS_MARCA_CARRERA', jsonResponse['marca_carrera']);
      sharedPreferences.setString(
          'LS_TIPO_CARRERA', jsonResponse['tipo_carrera']);
      sharedPreferences.setString(
          'LS_USER_ID', jsonResponse['user_id'].toString());

      sharedPreferences.setString('LS_USER_USER', user);
      sharedPreferences.setString('LS_USER_PASS', pass);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      setState(() {
        _isLogin = false;
      });
      _showAlertDialog(context);
    }
  }

  Widget _btnsplash(BuildContext context) {
    return Positioned(
      bottom: 60.0,
      left: 20.0,
      right: 20.0,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isLogin = true;
          });
          getLogin(_usuario.text, _contrasena.text, context);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.purple,
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Center(
              child: Text(
                "Iniciar",
                style: TextStyle(color: Colors.white, fontSize: 25.0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _panelFondo() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bg.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _panelTexto(String text1, text2) {
    return Positioned(
      bottom: 130.0,
      left: 0.0,
      right: 0.0,
      child: Center(
        child: Column(
          children: [
            Text(
              text1,
              style: TextStyle(
                fontSize: 30.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              text2,
              style: TextStyle(
                fontSize: 30.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            _panelLogin(),
          ],
        ),
      ),
    );
  }

  Widget _panelLogin() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
          child: Column(
            children: [
              Padding(
                //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
                padding: EdgeInsets.symmetric(horizontal: 15),

                child: TextField(
                  controller: _usuario,
                  decoration: InputDecoration(
                      fillColor: Colors.white,
                      focusColor: Colors.white,
                      filled: true,
                      // border: OutlineInputBorder(),
                      // labelText: 'Email',
                      hintText: 'example@mail.com'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  controller: _contrasena,
                  obscureText:
                      !_passwordVisible, //This will obscure text dynamically
                  decoration: InputDecoration(
                      fillColor: Colors.white,
                      focusColor: Colors.white,
                      filled: true,
                      // hintStyle: TextStyle(color: Colors.purple),
                      // border: OutlineInputBorder(),
                      // labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          // Based on passwordVisible state choose the icon
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.purple,
                        ),
                        onPressed: () {
                          // Update the state i.e. toogle the state of passwordVisible variable
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                      hintText: 'Contraseña'),
                ),
              ),

              // _inputPass(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _panelLoading() {
    return Stack(
      children: [
        Positioned(
            top: 0.0,
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.purple.shade300,
              ),
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 5.0,
                    color: Colors.white,
                    backgroundColor: Colors.purple,
                  ),
                  Image.asset('assets/logoPucelaRun.png'),
                ],
              )),
            )),
      ],
    );
  }

  void _showAlertDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (buildcontext) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Nombre de usuario o contraseña incorrecto."),
            actions: <Widget>[
              RaisedButton(
                child: Text(
                  "Ok",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // FullScreen.enterFullScreen(FullScreenMode.EMERSIVE_STICKY);
    return Scaffold(
      body: !_isLogin
          ? Stack(
              children: [
                _panelFondo(),
                Positioned(
                  top: 20.0,
                  bottom: 420.0,
                  left: 10.0,
                  right: 10.0,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/logoPucelaRun.png'),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                ),
                _panelTexto("Presencial o Virtual", "10K. 5K. 2K"),
                _btnsplash(context),
              ],
            )
          : _panelLoading(),
    );
  }
}
