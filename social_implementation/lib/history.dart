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
  runApp(HistoryPage());
}

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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


class _MyHomePageState extends State<MyHomePage> {
  double _currentPosition = 0.0; // 現在の再生位置
  double _totalDuration = 0.0; // 音声ファイルの総再生時間
  bool _recordingStatus = false; // 録音状態(true:録音中/false:停止中)
  bool _playingStatus = false; // 再生状態(true:再生中/false:停止中)
  Map<String, bool> _playingStatusMap = {};
  AudioPlayer audioPlayer = AudioPlayer();
  Directory appDocDir =Directory('');
  List<FileSystemEntity> files = List<FileSystemEntity>.empty(growable: true);
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _Setfiles();
  }

  void _onSliderChanged(double value) async {
    // スライダーの値に合わせて音声の再生位置を変更する
    await audioPlayer.seek(Duration(milliseconds: value.toInt()));
  }

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

  void _startPlaying(String filename) async {
    // 再生するファイルを指定
    final directory = await getApplicationDocumentsDirectory();
    String pathToWrite = directory.path;
    final localFile = '$pathToWrite/recording/$filename';



    // 再生開始
    await audioPlayer.play(DeviceFileSource(localFile));

    /*duration 再生時間の取得
    player.onDurationChanged.listen((Duration d) {
      print('Max duration: $d');
      setState(() => duration = d);
    });
    */
    // 再生終了後、ステータス変更
    audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _playingStatus = false;
      });
    });
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

  //再生中に表示するウィジェット
  Widget _buildPlaybackWidget() {
    List<Widget> playbackWidgets = [];

    _playingStatusMap.forEach((filename, isPlaying) {
      if (isPlaying) {
        playbackWidgets.add(
          Column(
            children: [
              Container(
                padding: EdgeInsets.all(8.0),
                color: Colors.blue,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Now playing: $filename',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    ElevatedButton(
                      onPressed: () {
                        _pausePlaying();
                      },
                      child: Text('Pause'),
                    ),
                  ],
                ),
              ),
              // 追加: 再生バー
              Slider(
                value: 0.0,
                onChanged: _onSliderChanged,
                min: 0.0,
                max: 0.0,
                //max: duration,
              ),
            ],
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
      appBar: Header(text: "録音履歴"),
      backgroundColor: Color.fromRGBO(254, 246, 228, 1),
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: ListView.builder(
                itemCount: files.length,
                itemBuilder: (context, index) {
                  String fileName = basename(files[index].path);
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                    color: Colors.lightBlue[50],
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(fileName),
                          tileColor: Colors.blue[50],
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  _playingHandle(fileName);
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  primary: Colors.lightBlue,
                                ),
                                child: _playingStatusMap[fileName] ?? false
                                    ? const Icon(Icons.stop)
                                    : const Icon(Icons.play_arrow),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _deleteFile(fileName);
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  primary: Colors.lightBlue,
                                ),
                                child: const Icon(Icons.delete),
                              ),
                            ],
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
            ),
          ),
          _buildPlaybackWidget(), // ここで再生中のウィジェットを表示
        ],
      ),
      bottomNavigationBar: Footer(currentIndex: 2, context: context),
    );
  }
}