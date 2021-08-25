import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimerCountDownWidget extends StatefulWidget {
  Function onTimerFinish;

  TimerCountDownWidget({required this.onTimerFinish}) : super();

  @override
  State<StatefulWidget> createState() => TimerCountDownWidgetState();
}

class TimerCountDownWidgetState extends State<TimerCountDownWidget>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  int _countdownTime = 5;

  late AnimationController _animationController;
  late Animation _animation;

  @override
  void initState() {
    startCountdownTimer();

    // TODO: implement initState
    _animationController =
        AnimationController(duration: Duration(seconds: 10), vsync: this);
    _animationController.repeat(reverse: true);
    _animation = Tween(begin: 1.0, end: 55.0).animate(_animationController)
      ..addListener(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.withOpacity(0.5),
      body: Center(
        child: Container(
          width: 250,
          height: 250,
          child: Center(
            child: Text(
              _countdownTime > 0 ? "$_countdownTime" : "0",
              style: GoogleFonts.oswald(
                textStyle: TextStyle(
                    color: _countdownTime > 0
                        ? Colors.purple
                        : Color.fromARGB(255, 17, 132, 255),
                    fontSize: 150.0,
                    letterSpacing: 0.5),
              ),
            ),
          ),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black87,
              boxShadow: [
                BoxShadow(
                    color: Color.fromARGB(130, 237, 125, 58),
                    blurRadius: _animation.value,
                    spreadRadius: _animation.value)
              ]),
        ),
      ),
    );
  }

  void startCountdownTimer() {
//    const oneSec = const Duration(seconds: 1);
//    var callback = (timer) => {
//      setState(() {
//        if (_countdownTime < 1) {
//          widget.onTimerFinish();
//          _timer.cancel();
//        } else {
//          _countdownTime = _countdownTime - 1;
//        }
//      })
//    };
//
//    _timer = Timer.periodic(oneSec, callback);

    _timer = Timer.periodic(
        Duration(seconds: 1),
        (Timer timer) => {
              setState(() {
                if (_countdownTime < 2) {
                  widget.onTimerFinish();
                  _timer.cancel();
                } else {
                  _countdownTime = _countdownTime - 1;
                }
              })
            });
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
    super.dispose();
  }
}
