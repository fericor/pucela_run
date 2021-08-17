import 'package:flutter/material.dart';
import 'package:pucela_run/pages/map_page.dart';

import 'home_page.dart';

class splashPage extends StatelessWidget {
  const splashPage({Key? key}) : super(key: key);

  Widget _btnsplash(BuildContext context){
    return Positioned(
      bottom: 60.0,
      left: 20.0,
      right: 20.0,
      child: GestureDetector(
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.purple,
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(child: Text("Iniciar", style: TextStyle(color: Colors.white, fontSize: 25.0),),),
          ),
        ),
      ),
    );
  }

  Widget _panelFondo(){
    return Container(
      decoration: BoxDecoration(
        image:DecorationImage(
          image: AssetImage('assets/bg.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _panelTexto(String text1, text2){
    return Positioned(
      bottom: 130.0,
      left: 0.0,
      right: 0.0,
      child: Center(
      child: Column(
        children: [
          Text(text1, style: TextStyle(fontSize: 30.0, color: Colors.white, fontWeight: FontWeight.bold,),),
          Text(text2, style: TextStyle(fontSize: 30.0, color: Colors.white, fontWeight: FontWeight.bold,),),
        ],
      ),),);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _panelFondo(),
          Positioned(
            top: 100.0,
            bottom: 220.0,
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
          _panelTexto("Presencial o Virtual","10K. 5K. 2K"),
          _btnsplash(context),
        ],
      ),
    );
  }
}
