<<<<<<< Updated upstream

=======
import 'dart:core';
import 'package:SI/components/fotter.dart';
>>>>>>> Stashed changes
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
<<<<<<< Updated upstream
import 'package:path/path.dart';
=======
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'dart:math';

>>>>>>> Stashed changes
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _Start();
    return MaterialApp(
      title: 'Record Demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Record Demo'),
        ),
        body: const Center(
          child: MyHomePage(),
        ),
      ),
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
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
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
<<<<<<< Updated upstream
=======
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
>>>>>>> Stashed changes

  // 録音開始
  void _startRecording() async {
    // 権限確認

    if (await record.hasPermission()) {
      // 録音ファイルを指定
      final directory = await getApplicationDocumentsDirectory();
      // recording フォルダのパスを作成
<<<<<<< Updated upstream
      final recordingFolderPath = '${appDocDir.path}/recording';

      // フォルダが存在しない場合は作成
      if (!Directory(recordingFolderPath).existsSync()) {
        Directory(recordingFolderPath).createSync(recursive: true);
        print('recording フォルダが作成されました。');
      } else {
        print('recording フォルダは既に存在しています。');
      }
=======
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
=======

    print("録音画面${files.length}");
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream

  // 再生一時停止
  void _pausePlaying() async {
    await audioPlayer.pause();
  }

=======
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream

  // 再生の開始停止
  void _playingHandle() {
    setState(() {
      // 録音中の場合は録音停止
      if (_recordingStatus) {
        _recordingStatus = false;
        _stopRecording();
      }
=======
  // 自動録音の開始停止
  Future<void> _AutorecordingHandle() async {
    int n=0;
    _AutorecordingStatus = !_AutorecordingStatus;
>>>>>>> Stashed changes

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

<<<<<<< Updated upstream
  // ステータスメッセージ
  String _statusMessage() {
    String msg = '';

    if(_recordingStatus) {
      if (_playingStatus) {
        msg = '-'; // 録音○、再生○（発生しない）
      } else {
        msg = '録音中'; // 録音×、再生○
      }
    } else {
      if (_playingStatus) {
        msg = '再生中'; // 録音○、再生×
      } else {
        msg = '待機中'; // 録音×、再生×
      }
    }

    return msg;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
=======
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
>>>>>>> Stashed changes

        decoration: BoxDecoration(
            color: Color.fromRGBO(254, 246, 228, 1)
        ),
        padding: const EdgeInsets.all(50.0),
        child: Column(
          children: <Widget>[

<<<<<<< Updated upstream
            // ステータスメッセージ
            Text(
              _statusMessage(),
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 40.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            // 縦スペース
            const SizedBox(height: 30,),
            // 2つのボタン
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 録音ボタン
                TextButton(
                  onPressed: _recordingHandle,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                  ),
                  child: Text(
                    _recordingStatus ? "停止" : '録音',
                    style: const TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                ),
                // 再生ボタン
                SizedBox(
                  height: 50, // ボタンのサイズ調整
                  child: ElevatedButton(
                    onPressed: () {_playingHandle();},
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      primary: Colors.lightBlue,
                    ),
                    child: _playingStatus ? const Icon(Icons.stop) : const Icon(Icons.play_arrow),
                  ),
                ),
              ],
            ),
            Expanded(
                child: Container(
=======
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
>>>>>>> Stashed changes

                  child: ListView.builder(
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      String fileName = basename(files[index].path); // ファイル名を取
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 5.0), // リストアイテムの上下の間隔
                        color: Colors.lightBlue[50],
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(fileName),
                              tileColor: Colors.blue[50],
                              trailing: ElevatedButton(
                                onPressed: () {_playingHandle();},
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  primary: Colors.lightBlue,
                                ),
                                child: _playingStatus ? const Icon(Icons.stop) : const Icon(Icons.play_arrow),
                              ),
                            ),
                            Divider(
                              height: 1,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      );

                    },
                  ),
                )
            ),
          ],
        ));

  }
}
double log10(num x) => x > 0 ? log(x) / ln10 : double.nan;