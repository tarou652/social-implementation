
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _recordingStatus = false; // 録音状態(true:録音中/false:停止中)
  bool _playingStatus = false; // 再生状態(true:再生中/false:停止中)
  Record record = Record();
  AudioPlayer audioPlayer = AudioPlayer();
  String filename="";
  Directory appDocDir =Directory('');
  List<FileSystemEntity> files = List<FileSystemEntity>.empty(growable: true);

  // 録音開始
  void _startRecording() async {
    // 権限確認
    if (await record.hasPermission()) {
      // 録音ファイルを指定
      final directory = await getApplicationDocumentsDirectory();
      // recording フォルダのパスを作成
      final recordingFolderPath = '${appDocDir.path}/recording';

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

  // 再生一時停止
  void _pausePlaying() async {
    await audioPlayer.pause();
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

        decoration: BoxDecoration(
            color: Color.fromRGBO(254, 246, 228, 1)
        ),
        padding: const EdgeInsets.all(50.0),
        child: Column(
          children: <Widget>[

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