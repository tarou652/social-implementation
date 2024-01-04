import 'package:SI/components/footer.dart';
import 'package:SI/components/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:core';
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
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
void main() {
  runApp(
    SettingPage(),);
}

class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _Start();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
  void _Start() async{
    final directory = await getApplicationDocumentsDirectory();
    // recording フォルダのパスを作成
    final AutoFolderPath = '${directory.path}/Auto';
    final recordingFolderPath = '${directory.path}/recording';
    // ディレクトリが存在するか確認
    bool Reexists = await Directory(recordingFolderPath).exists();
    bool Autoexists = await Directory(AutoFolderPath).exists();
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

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  DateTime dateTime = DateTime.now();
  bool _value = true;
  List<DateTime> history = [];
  List<bool> historySwitchValues = List.generate(100, (index) => true);
  bool _recordingStatus = false; // 録音状態(true:録音中/false:停止中)
  bool _playingStatus = false; // 再生状態(true:再生中/false:停止中)
  bool _AutorecordingStatus = false; // 録音状態(true:録音中/false:停止中)
  final config = RecordConfig(
    bitRate: 64000,
    numChannels: 2,
  );
  var rng = Random();
  AudioPlayer audioPlayer = AudioPlayer();
  String filename="";
  String LatestCreatefile ="";
  Directory appDocDir =Directory('');
  List<FileSystemEntity> files = List<FileSystemEntity>.empty(growable: true);
  int _recordDuration = 0;
  Timer? _timer2;
  bool _oversound=false;
  var _timer;
  late final AudioRecorder record;
  RecordState _recordState = RecordState.stop;
  StreamSubscription<Amplitude>? _amplitudeSub;
  Amplitude? _amplitude;
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
  //バックグラウンドでの処理
  //timeの書きかたfinal alarm = DateTime.utc(2023, 3, 7, 2);
  Future<void> _BG(time) async {
    var id = rng.nextInt(100000000000);
    await AndroidAlarmManager.oneShotAt(
      time,
      id,
      _AutorecordingHandle,
      alarmClock: true,
      allowWhileIdle: true,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
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
  void saveDateTime(){
    setState((){
      history.add(dateTime);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(text: "設定"),
      backgroundColor: Color(0xffFEF6E4),
      body: SingleChildScrollView(
        child: _form(),
      ),
      bottomNavigationBar:Footer(currentIndex: 1,context: context),
    );
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '時間指定',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff001858),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    saveDateTime();
                  },
                  style: TextButton.styleFrom(
                    primary: Color(0xffF582AE),
                  ),
                  child: Text(
                    '保存',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Divider(
              thickness: 1, // 区切り線の太さを指定
              color: Color(0xffB2B3BA), // 区切り線の色を指定
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: CupertinoDatePicker(
                initialDateTime: dateTime,
                mode: CupertinoDatePickerMode.dateAndTime,
                use24hFormat: true,
                onDateTimeChanged: (DateTime newTime) {
                  setState(() => dateTime = newTime);
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '自動録音',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff001858),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CupertinoSwitch(
                  activeColor: Color(0xff8BD3DD),
                  trackColor: Color(0xff545C81),
                  value: _value,
                  onChanged: (value) => setState(() => _value = value),
                ),
              ],
            ),
            Divider(
              thickness: 1, // 区切り線の太さを指定
              color: Color(0xffB2B3BA), // 区切り線の色を指定
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '指定履歴',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff001858),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Divider(
              thickness: 1, // 区切り線の太さを指定
              color: Color(0xffB2B3BA), // 区切り線の色を指定
            ),
            SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: history.asMap().entries.map((entry) {
                  final index = entry.key;
                  final savedDateTime = entry.value;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${savedDateTime.year}/${savedDateTime.month}/${savedDateTime.day}',
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: Color(0xff001858),
                                    fontWeight: FontWeight.bold, // 太文字にする
                                  ),
                                ),
                                Text(
                                  '${savedDateTime.hour}:${savedDateTime.minute}',
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: Color(0xff001858),
                                    fontWeight: FontWeight.bold, // 太文字にする
                                  ),
                                ),
                              ],
                            ),
                            CupertinoSwitch(
                              activeColor: Color(0xff8BD3DD),
                              trackColor: Color(0xff545C81),
                              value: historySwitchValues[index],
                              onChanged: (value) {
                                setState(() {
                                  historySwitchValues[index] = value;
                                });
                              },
                            ),
                          ],
                        ),
                        Divider(
                          thickness: 1, // 区切り線の太さを指定
                          color: Color(0xffB2B3BA), // 区切り線の色を指定
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}