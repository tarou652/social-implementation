import 'dart:core';
import 'package:SI/components/fotter.dart';
import 'package:flutter/material.dart';
import 'package:SI/components/header.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'dart:math';

void main() {
  runApp(Myapp());
}

class Myapp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _Start();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
  void _Start() async{
    final directory = await getApplicationDocumentsDirectory();
    // recording フォルダのパスを作成
    final AutoFolderPath = '${directory.path}/Auto';
    final recordingFolderPath = '${directory.path}/recording';
    final synthesisFolderPath = '${directory.path}/synthesis';
    // ディレクトリが存在するか確認
    bool Reexists = await Directory(recordingFolderPath).exists();
    bool Autoexists = await Directory(AutoFolderPath).exists();
    // bool synthesisexists = await Directory(synthesisFolderPath).exists();
    // ディレクトリが存在しない場合、作成
    if (!Reexists) {
      await Directory(recordingFolderPath).create(recursive: true);
    }
    if (!Autoexists) {
      await Directory(AutoFolderPath).create(recursive: true);
    }
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
  bool _AutorecordingStatus = false; // 録音状態(true:録音中/false:停止中)
  final config = RecordConfig(
    bitRate: 64000,
    numChannels: 2,
  );
  String situation ="idle";
  AudioPlayer audioPlayer = AudioPlayer();
  String filename="";
  String LatestCreatefile ="";
  Directory appDocDir =Directory('');
  List<FileSystemEntity> files = List<FileSystemEntity>.empty(growable: true);
  var _timeString = '00:00:00';
  DateTime _startTime = DateTime.now();
  var _isStart = false;
  int _recordDuration = 0;
  Timer? _timer2;
  bool _oversound=false;
  var _timer;
  late final AudioRecorder record;
  RecordState _recordState = RecordState.stop;
  StreamSubscription<Amplitude>? _amplitudeSub;
  Amplitude? _amplitude;

  @override
  void initState() {
    record = AudioRecorder();
    _amplitudeSub = record
        .onAmplitudeChanged(const Duration(milliseconds: 300))
        .listen((amp) {
      setState(() => _amplitude = amp);
      judge(true);
    });

    super.initState();
  }

  // 録音開始
  void _startRecording() async {
    // 権限確認

    if (await record.hasPermission()) {
      // 録音ファイルを指定
      final directory = await getApplicationDocumentsDirectory();
      // recording フォルダのパスを作成
      String pathToWrite = directory.path;//アプリ専用ディレクトリのパスを保存。
      var now = DateTime.now();
      filename="${now.year},${now.month},${now.day},${now.hour},${now.minute},${now.second}";
      final localFile = '${pathToWrite}/recording/${filename}.m4a';
      // 録音開始
      await record.start(config, path: localFile);
    }
  }
  void judge(bool I){

    final sound = _amplitude?.current ?? -160.0;
    print(sound);
    if(sound > -3 && !_oversound){
      _oversound=true;

    }
    if(I==false){
      _oversound=false;
    }
  }

  // 録音開始
  void _AutostartRecording() async {
    // 権限確認
    if (await record.hasPermission()) {
      // 録音ファイルを指定
      final directory = await getApplicationDocumentsDirectory();
      String pathToWrite = directory.path;//アプリ専用ディレクトリのパスを保存。
      var now = DateTime.now();
      filename="${now.year},${now.month},${now.day},${now.hour},${now.minute},${now.second}";
      final localFile = '${pathToWrite}/Auto/${filename}.m4a';

      // 録音開始
      await record.start(config, path: localFile);
      LatestCreatefile=localFile;

    }
  }
  Future<void> deletefile() async {
    if(_oversound){
      print("大きスギィ！");
    }else{
      final file = File(LatestCreatefile);

      if (await file.exists()) {
        await file.delete();
        print("消したよ");
      }else{
        print("ファイルが存在しないぞ");
        print(file);
      }
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
  // 録音停止
  void _AutostopRecording() async {
    await record.stop();

    appDocDir = await getApplicationDocumentsDirectory();
    final recordingFolderPath = '${appDocDir.path}/Auto';
    final recordingDirectory = Directory(recordingFolderPath);
    //judge(false);
    setState(() {
      // ディレクトリ内のファイルリストを取得
      files = recordingDirectory.listSync();
    });

    print("録音画面${files.length}");
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
  // 自動録音の開始停止
  Future<void> _AutorecordingHandle() async {
    int n=0;
    _AutorecordingStatus = !_AutorecordingStatus;

    while(_AutorecordingStatus){
      _AutostartRecording();
      await Future.delayed(Duration(seconds: 10));
      judge(true);
      deletefile();
      _AutostopRecording();
      judge(false);
      n++;
      print("今${n}回");
    }
    if(!_AutorecordingStatus){
      deletefile();
      _AutostopRecording();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(text: "録音画面"),
      backgroundColor: Color.fromRGBO(254, 246, 228, 1),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_amplitude != null) ...[
            const SizedBox(height: 40),
            Text('Current: ${_amplitude?.current ?? 0.0}'),
            Text('Max: ${_amplitude?.max ?? 0.0}'),
          ],
          Center(
            child: Text(_timeString, style: TextStyle(fontSize: 60)),
          ),
          Container(
            width: 100,
            height: 50,
            color: Colors.greenAccent,
            child: TextButton(
                onPressed:() async {

                  _startTimer();
                  _recordingHandle();

                },
                child: Text(_isStart ? 'STOP' : 'START')),
          ),
          Container(
            width: 100,
            height: 50,
            color: Colors.redAccent,
            child: TextButton(
                onPressed:() async {

                  _startTimer();
                  _AutorecordingHandle();

                },
                child: Text(_isStart ? 'STOP' : 'START')),
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
double log10(num x) => x > 0 ? log(x) / ln10 : double.nan;