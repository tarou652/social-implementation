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

  // 再生一時停止
  void _pausePlaying() async {
    await audioPlayer.pause();
  }
  // 再生の開始停止
  void _playingHandle(String filename) {
    setState(() {
      // 録音中の場合は録音停止
      if (_recordingStatus) {
        _recordingStatus = false;
      }

      _playingStatusMap[filename] = !_playingStatusMap[filename];
      if (_playingStatus) {
        _startPlaying(filename);
      } else {
        _pausePlaying();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(text: "録音履歴"),
      backgroundColor: Color.fromRGBO(254, 246, 228, 1),
      body: Column(
          children:[ Expanded(
              child: Container(

                child: ListView.builder(
                  itemCount: files.length,

                  itemBuilder: (context, index) {
                    String fileName = basename(files[index].path); // ファイル名を取
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 5.0,horizontal: 20.0), // リストアイテムの上下の間隔
                      color: Colors.lightBlue[50],
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(fileName),
                            tileColor: Colors.blue[50],
                            trailing: ElevatedButton(
                              onPressed: () {_playingHandle(fileName);},
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
      ),

      bottomNavigationBar:Footer(currentIndex: 2,context: context),

    );

  }
}