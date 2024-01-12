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
  double _currentPosition = 0.0; // 現在の再生位置
  double _totalDuration = 0.0; // 音声ファイルの総再生時間
  bool _recordingStatus = false; // 録音状態(true:録音中/false:停止中)
  bool _playingStatus = false; // 再生状態(true:再生中/false:停止中)
  int dB = 0;
  Map<String, bool> _playingStatusMap = {};
  Record record = Record();
  late final AudioRecorder record;
  final config = RecordConfig(
    bitRate: 64000,
    numChannels: 2,
  );
  AudioPlayer audioPlayer = AudioPlayer();
  String filename="";
  Directory appDocDir =Directory('');
  List<FileSystemEntity> files = List<FileSystemEntity>.empty(growable: true);
  var _timeString = '00:00:00';

  DateTime _startTime = DateTime.now();

  var _timer;
  var _isStart = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _Setfiles();
  }

  void initState() {
    record = AudioRecorder();
    super.initState();
  }
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
      await record.start(config, path: localFile);
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

  //リストからファイル削除
  void _deleteFile(String filename) async {
    // Get the index of the file in the list
    int index = files.indexWhere((file) => basename(file.path) == filename);

    // Remove the file from the list
    files.removeAt(index);

    // Remove the file from the file system
    final file = File('${appDocDir.path}/recording/$filename');
    if (await file.exists()) {
      await file.delete();
      print("消したよ");
    }

    // Remove the entry from the map
    _playingStatusMap.remove(filename);

    // Update the state to reflect the changes
    setState(() {});
  }

  //ファイルのセッティング
  void _Setfiles() async {

    appDocDir = await getApplicationDocumentsDirectory();
    final recordingFolderPath = '${appDocDir.path}/recording';
    final recordingDirectory = Directory(recordingFolderPath);
    files = recordingDirectory.listSync();
    // 各ファイル名に対してマップにエントリーを追加
    for (var file in files) {
      String fileName = basename(file.path);
      _playingStatusMap[fileName] = false;
    }
    print("履歴画面${files.length}");
    // ウィジェットを再描画
    setState(() {});
  }

  // 再生開始
  void _startPlaying(String filename) async {

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

  void _onSliderChanged(double value) async {
    // スライダーの値に合わせて音声の再生位置を変更する
    await audioPlayer.seek(Duration(milliseconds: value.toInt()));
  }

  // 再生一時停止
  void _pausePlaying() async {
    await audioPlayer.pause();
  }
  // 再生の開始停止
  void _playingHandle(String filename) {
    print(filename);
    setState(() {
      // 録音中の場合は録音停止
      if (_recordingStatus) {
        _recordingStatus = false;
      }
      // 再生中の場合は停止、停止中の場合は再生
      _playingStatusMap[filename] = !_playingStatusMap[filename]!;

      if (_playingStatusMap[filename]!) {
        _startPlaying(filename);
      } else {
        _pausePlaying();
      }
    });
  }

  Widget _buildPlaybackWidget() {
    List<Widget> playbackWidgets = [];

    _playingStatusMap.forEach((filename, isPlaying) {
      if (isPlaying) {
        playbackWidgets.add(
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), // 角を丸くする
              color: Colors.grey.withOpacity(0.5), // 背景の色
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '再生中: $filename',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });

    return Column(
      children: playbackWidgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(text: "録音画面"),
      backgroundColor: Color.fromRGBO(254, 246, 228, 1),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Container(
            child: Text(
              _timeString,
              style: TextStyle(fontSize: 60),
            ),
          ),

          SizedBox(height: 20),

          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle, // ボタンを丸くする
              color: Colors.greenAccent,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(50), // InkWell の角丸を指定（半分のサイズ）
              onTap: () async {
                _startTimer();
                _recordingHandle();
              },
              child: Center(
                child: Text(
                  _isStart ? '停止' : '開始',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),

          Flexible(
            child: Container(
              child: ListView.builder(
                physics: ClampingScrollPhysics(),
                itemCount: files.length,
                itemBuilder: (context, index) {
                  String fileName = basename(files[index].path);
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), // 丸くする
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(fileName),
                          //tileColor: Colors.blue[50],
                          subtitle: Text('最大デシベル音：${dB}dB'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  _playingHandle(fileName);
                                },

                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  primary: Colors.transparent, // ボタンの背景を透明にする
                                  elevation: 0, // ボタンの影を削除
                                ),

                                child: _playingStatusMap[fileName] ?? false
                                    ? const Icon(Icons.stop, color: Colors.grey)
                                    : const Icon(Icons.play_arrow, color: Colors.grey),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _deleteFile(fileName);
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
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          _buildPlaybackWidget(), // ここで再生中のウィジェットを表示
        ],
      ),
      bottomNavigationBar:Footer(currentIndex: 0,context: context,selected: 0),
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