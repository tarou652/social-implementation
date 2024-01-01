import 'package:SI/components/footer.dart';
import 'package:flutter/material.dart';
import 'package:SI/components/header.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';

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
  bool _recordingStatus = false; // 録音状態(true:録音中/false:停止中)
  bool _playingStatus = false; // 再生状態(true:再生中/false:停止中)
  Record record = Record();
  AudioPlayer audioPlayer = AudioPlayer();
  String filename="";
  Directory appDocDir =Directory('');
  List<FileSystemEntity> files = List<FileSystemEntity>.empty(growable: true);
  var _timeString = '00:00:00';

  DateTime _startTime = DateTime.now();

  var _timer;
  var _isStart = false;
  // 録音開始
  void _startRecording() async {
    // 権限確認
    if (await record.hasPermission()) {
      // 録音ファイルを指定
      final directory = await getApplicationDocumentsDirectory();
      // recording フォルダのパスを作成
      final recordingFolderPath = '${directory.path}/recording';

      // フォルダが存在しない場合は作成
      if (!Directory(recordingFolderPath).existsSync()) {
        Directory(recordingFolderPath).createSync(recursive: true);
        print('recording フォルダが作成されました。');
      } else {
        print('recording フォルダは既に存在しています。');
      }
      String pathToWrite = directory.path;//アプリ専用ディレクトリのパスを保存。
      var now = DateTime.now();
      filename="${now.year},${now.month},${now.day},${now.hour},${now.minute},${now.second}";
      final localFile = '${pathToWrite}/recording/${filename}.m4a';

      // 録音開始
      await record.start(
        path: localFile,
        encoder: AudioEncoder.aacLc, // by default
        bitRate: 128000, // by default
        samplingRate: 44100, // by default
      );
    }
  }

  // 録音停止
  void _stopRecording() async {
    await record.stop();
    appDocDir = await getApplicationDocumentsDirectory();
    final recordingFolderPath = '${appDocDir.path}/recording';
    final recordingDirectory = Directory(recordingFolderPath);

    setState(() {
      // ディレクトリ内のファイルリストを取得
      files = recordingDirectory.listSync();
    });
    print("録音画面${files.length}");
  }

  // 再生開始
  void _startPlaying() async {
    // 再生するファイルを指定
    final directory = await getApplicationDocumentsDirectory();
    String pathToWrite = directory.path;
    final localFile = '$pathToWrite/recording/$filename.m4a';

    // 再生開始
    await audioPlayer.play(DeviceFileSource(localFile));

    // 再生終了後、ステータス変更
    audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _playingStatus = false;
      });
    });
  }



  // 録音の開始停止
  void _recordingHandle() {
    // 再生中の場合は何もしない
    if (_playingStatus) {return;}

    setState(() {
      _recordingStatus = !_recordingStatus;
      if (_recordingStatus) {
        _startRecording();
      } else {
        _stopRecording();
      }
    });
  }
  // 再生一時停止
  void _pausePlaying() async {
    await audioPlayer.pause();
  }
  // 再生の開始停止
  void _playingHandle() {
    setState(() {
      // 録音中の場合は録音停止
      if (_recordingStatus) {
        _recordingStatus = false;
        _stopRecording();
      }

      _playingStatus = !_playingStatus;
      if (_playingStatus) {
        _startPlaying();
      } else {
        _pausePlaying();
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(text: "録音画面"),
      backgroundColor: Color.fromRGBO(254, 246, 228, 1),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start, // ここをMainAxisAlignment.startに変更
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Container(
            width: 100,
            height: 50,
            color: Colors.greenAccent,
            child: TextButton(
                onPressed:() async {

                  _startTimer();
                  _recordingHandle();

                },
                child: Text(_isStart ? 'STOP' : 'START'),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: Text(
              _timeString,
              style: TextStyle(fontSize: 60),
            ),
          ),
        ],
      ),
      bottomNavigationBar:Footer(currentIndex: 0,context: context),
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