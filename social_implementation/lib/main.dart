import 'package:SI/components/fotter.dart';
import 'package:flutter/material.dart';
import 'package:SI/components/header.dart';
import 'dart:async';
import 'package:intl/intl.dart';

void main() {
  runApp(Myapp());
}

class Myapp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}
class ClockTimer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {

  var _timeString = '00:00:00';

  DateTime _startTime = DateTime.now();

  var _timer;
  var _isStart = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(text: "録音画面"),
      backgroundColor: Color.fromRGBO(254, 246, 228, 1),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(_timeString, style: TextStyle(fontSize: 60)),
          ),
          Container(
            width: 100,
            height: 50,
            color: Colors.greenAccent,
            child: TextButton(
                onPressed: _startTimer,
                child: Text(_isStart ? 'STOP' : 'START')),
          )
        ],
      ),
      bottomNavigationBar:Footer(currentIndex: 3,context: context),
    );
  }
  void _startTimer() {
    setState(() {
      _isStart = !_isStart;
      if (_isStart) {
        _startTime = DateTime.now();
        _timer  = Timer.periodic(Duration(seconds: 1), _onTimer);
      } else {
        _timer.cancel();
      }
    });
  }

  void _onTimer(Timer timer) {
    /// 現在時刻を取得
    var now = DateTime.now();
    /// 開始時刻と比較して差分を取得
    var diff = now.difference(_startTime).inSeconds;

    /// タイマーのロジック
    var hour = (diff / (60 * 60)).floor();
    var mod = diff % (60 * 60);
    var minutes = (mod / 60).floor();
    var second = mod % 60;

    setState(() => {
      _timeString = """${_convertTwoDigits(hour)}:${_convertTwoDigits(minutes)}:${_convertTwoDigits(second)}"""
    });
  }

  String _convertTwoDigits(int number) {
    return number >= 10 ? "$number" : "0$number";
  }
}