import 'package:SI/components/footer.dart';
import 'package:SI/components/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:core';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:workmanager/workmanager.dart';
import 'dart:math';
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    // バックグラウンドで実行したいタスクの処理をここに記述
    if (task == "scheduledTask") {
      scheduledTask();
    }
    return Future.value(true);
  });

}
void scheduledTask() {
  // バックグラウンドで実行したい処理をここに記述
  print("Background task executed: scheduledTask");
}
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true, // デバッグモードの場合は true に設定
  );
  DateTime scheduledTime = DateTime.now().add(Duration(minutes: 1));
  Workmanager().registerPeriodicTask(
    "1",
    "simplePeriodicTask",
    initialDelay: scheduledTime.difference(DateTime.now()),
  );
  runApp(
    SettingPage(),);
}

class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _Start();
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
  void _Start() async{
    final directory = await getApplicationDocumentsDirectory();
    // recording フォルダのパスを作成
    final AutoFolderPath = '${directory.path}/Auto';
    final recordingFolderPath = '${directory.path}/recording';
    final historyfolderpath = '${directory.path}/history';
    final dbfolderpath = '${directory.path}/db';
    // ディレクトリが存在するか確認
    bool Reexists = await Directory(recordingFolderPath).exists();
    bool Autoexists = await Directory(AutoFolderPath).exists();
    bool Historyexists = await Directory(historyfolderpath).exists();
    bool dbexists =await Directory(dbfolderpath).exists();
    // ディレクトリが存在しない場合、作成
    if (!Reexists) {
      await Directory(recordingFolderPath).create(recursive: true);
    }
    if (!Autoexists) {
      await Directory(AutoFolderPath).create(recursive: true);
    }
    if (!Historyexists) {
      await Directory(historyfolderpath).create(recursive: true);
    }
    if (!dbexists) {
      await Directory(dbfolderpath).create(recursive: true);
    }
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  DateTime dateTime = DateTime.now();
  List<String> history = [];
  List<bool> historySwitchValues = List.generate(100, (index) => true);
  bool _AutorecordingStatus = false; // 録音状態(true:録音中/false:停止中)
  final config = RecordConfig(
    bitRate: 64000,
    numChannels: 2,
  );
  late Directory directory = Directory('');
  var rng = Random();
  AudioPlayer audioPlayer = AudioPlayer();
  String filename="";
  String LatestCreatefile ="";
  Directory appDocDir =Directory('');
  List<FileSystemEntity> files = List<FileSystemEntity>.empty(growable: true);
  bool _oversound=false;
  int _Maxsound =0;
  var _timer;
  late final AudioRecorder record;
  RecordState _recordState = RecordState.stop;
  StreamSubscription<Amplitude>? _amplitudeSub;
  Amplitude? _amplitude;
  //起動したらよびだされるもの
  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();

    directory = await getApplicationDocumentsDirectory();
    SetDateTime();
  }
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
  Future<void> judge(bool I) async {

    final sound = _amplitude?.current ?? -160.0;
    final Sound = (sound + 77);
    print("${Sound}db");
    if(Sound > 40 && !_oversound){
      //oversoundをTrueにすることで生成してすぐに消すコードをとめるようにする
      _oversound=true;
      //ここからは最大DBを保存するコード。ファイルの中の順番が新しいファイルが上にくるようにdbNumで調整する。
      final dbFolderPath = '${directory.path}/db';
      final dbDirectory = Directory(dbFolderPath);
      final dbPaths = dbDirectory.listSync();
      final dbNum = 1000 - dbPaths.length;
      final txtfile = File('$dbFolderPath/$dbNum,$_Maxsound');
      if (!await txtfile.exists()) {
    await txtfile.create();
    }
      print(dbPaths);
    }
    if(sound > _Maxsound){
      _Maxsound=Sound as int;
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
    _Maxsound=0;
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
  Future<void> SetDateTime() async {
    final historyFolderPath = '${directory.path}/history';
    final historyDirectory = Directory(historyFolderPath);
    final historypaths = historyDirectory.listSync();
    List<String> itizilist =[];
    for (var file in historypaths) {
      String fileName = basename(file.path);
      itizilist.add(fileName);
    }
    history = itizilist;
    setState(() {});
    print(history);
  }

  Future<void> saveDateTime(DateTime start, DateTime end) async {

    final historyFolderPath = '${directory.path}/history';
    final historyDirectory = Directory(historyFolderPath);
    final endtime =start.add(Duration(hours: end.hour,minutes: end.minute));
    final txtfile = File('${historyFolderPath}/${start.year}.${start.month}.${start.day},${start.hour.toString().padLeft(2, '0')}.${start.minute.toString().padLeft(2, '0')}~${endtime.hour.toString().padLeft(2, '0')}.${endtime.minute.toString().padLeft(2, '0')}');
    if (!await txtfile.exists()) {
      await txtfile.create();
    }
    final historypaths = historyDirectory.listSync();
    List<String> itizilist =[];
    for (var file in historypaths) {
      String fileName = basename(file.path);
      itizilist.add(fileName);
    }
    history = itizilist;
    setState(() {});
    print(history);
  }
  Future<void> Deletedbfile(index) async {
    // DBフォルダのリストを作ってそこからindex番目のものを消す
    final dbFolderPath = '${directory.path}/db';
    final dbDirectory = Directory(dbFolderPath);
    final dbPaths = dbDirectory.listSync();
    List<String> itizilist =[];
    for (var file in dbPaths) {
      String fileName = basename(file.path);
      itizilist.add(fileName);
    }
    final dbList = itizilist;
    final dbFilename=dbList[index];
    final dbfile = File('$dbFolderPath/$dbFilename');
    if (await dbfile.exists()) {
      await dbfile.delete();
      print("DB消したよ");
    }
  }
  Future<void> DeleteDateTime(index) async {
    final historyFolderPath = '${directory.path}/history';
    final Filename=history[index];


    // Remove the file from the list
    history.removeAt(index);

    // Remove the file from the file system
    final file = File('$historyFolderPath/$Filename');
    if (await file.exists()) {
    await file.delete();
    print("消したよ");
    }

    setState((){
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
      bottomNavigationBar:Footer(currentIndex: 1,context: context,isStart: false,),
    );
  }
  int TimeHour = 1;
  int TimeMinute = 00;

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
                  onPressed: () async {
                    final endTime = DateTime(1, 1, 1, TimeHour, TimeMinute);
                    saveDateTime(dateTime,endTime);

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

            SizedBox(height: 16),
            // 追加: TextFieldウィジェット
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    DropdownButton<int>(
                      value: TimeHour,
                      onChanged: (int? newValue) {
                        setState(() {
                          TimeHour = newValue!;
                        });
                      },
                      items: <int>[0,1, 2, 3, 4,5,6,7,8]
                          .map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                    ),
                    Text('時'),
                    DropdownButton<int>(
                      value: TimeMinute,
                      onChanged: (int? newValue) {
                        setState(() {
                          TimeMinute = newValue!;
                        });
                      },
                      items: <int>[00,10, 20, 30, 40,50,]
                          .map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                    ),
                    Text('分後まで'),
                  ],
                ),
                SizedBox(height: 20.0), // 適宜スペースを追加



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
                  final entryData = entry.value;
                  List<String> parts = entryData.split(',');
                  final day  = parts[0];
                  final time = parts[1];
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
                                  '$day',
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: Color(0xff001858),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '$time',
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: Color(0xff001858),
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                DeleteDateTime(index);
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                primary: Colors.transparent, // 透明な背景色
                                elevation: 0, // ボタンの影を削除
                              ),
                              child: const Icon(Icons.delete, color: Colors.grey),
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