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
    _Start();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
void deleteFilesInDirectory(String directoryPath) {
  Directory directory = Directory(directoryPath);

  if (directory.existsSync()) {
    directory.listSync().forEach((FileSystemEntity file) {
      if (file is File) {
        file.deleteSync();
      }
    });
  }
}
void _Start() async{
  final directory = await getApplicationDocumentsDirectory();
  // recording フォルダのパスを作成
  final AutoFolderPath = '${directory.path}/Auto';
  final recordingFolderPath = '${directory.path}/recording';
  final historyfolderpath = '${directory.path}/history';
  final dbfolderpath = '${directory.path}/db';
  final Autodbfolderpath = '${directory.path}/Autodb';
  // ディレクトリが存在するか確認
  bool Reexists = await Directory(recordingFolderPath).exists();
  bool Autoexists = await Directory(AutoFolderPath).exists();
  bool Historyexists = await Directory(historyfolderpath).exists();
  bool dbexists =await Directory(dbfolderpath).exists();
  bool Autodbexists =await Directory(Autodbfolderpath).exists();
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
  if (!Autodbexists) {
    await Directory(Autodbfolderpath).create(recursive: true);
  }
  // // // 各フォルダ内のファイルを削除
  // deleteFilesInDirectory(AutoFolderPath);
  // deleteFilesInDirectory(recordingFolderPath);
  // deleteFilesInDirectory(historyfolderpath);
  // deleteFilesInDirectory(dbfolderpath);
  // deleteFilesInDirectory(Autodbfolderpath);
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

class _MyHomePageState extends State<MyHomePage>with SingleTickerProviderStateMixin  {
  bool _recordingStatus = false; // 録音状態(true:録音中/false:停止中)
  bool _playingStatus = false; // 再生状態(true:再生中/false:停止中)
  Map<String, bool> _playingStatusMap = {};
  late final AudioRecorder record;
  final config = RecordConfig(
    bitRate: 64000,
    numChannels: 2,
  );
  List<String> AutodbList=[];
  List<String> dbList=[];
  AudioPlayer audioPlayer = AudioPlayer();
  String filename="";
  List<FileSystemEntity> files = List<FileSystemEntity>.empty(growable: true);
  var _timeString = '00:00:00';
  DateTime dateTime = DateTime.now();
  List<String> history = [];
  List<bool> historySwitchValues = List.generate(100, (index) => true);
  bool _AutorecordingStatus = false; // 録音状態(true:録音中/false:停止中)
  late Directory directory = Directory('');
  String Autofilename="";
  String LatestCreatefile ="";
  Directory AutoappDocDir =Directory('');
  List<FileSystemEntity> Autofiles = List<FileSystemEntity>.empty(growable: true);
  bool _oversound=false;
  int _Maxsound =0;
  RecordState _recordState = RecordState.stop;
  StreamSubscription<Amplitude>? _amplitudeSub;
  Amplitude? _amplitude;
  TabController? _tabController;
  DateTime _startTime = DateTime.now();

  var _timer;


  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    directory = await getApplicationDocumentsDirectory();
    _Setfiles();



  }
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    record = AudioRecorder();
    _amplitudeSub = record
        .onAmplitudeChanged(const Duration(milliseconds: 300))
        .listen((amp) {
      setState(() => _amplitude = amp);
      judge(true,true);

  });}
  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
  // 録音開始
  void _startRecording() async {
    // 権限確認
    if (await record.hasPermission()) {
      // 録音ファイルを指定
      final directory = await getApplicationDocumentsDirectory();
      // recording フォルダのパスを作成
      final recordingFolderPath = '${directory.path}/recording';

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

    setState(() {
      // ディレクトリ内のファイルリストを取得
      _Setfiles();
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
        judge(true,false);
      } else {
        _Createdbfile(false);
        _stopRecording();
        judge(false,false);
      }
    });
  }
  Future<void> judge(bool I,_isAuto) async {

    final sound = _amplitude?.current ?? -160.0;
    final Sound = (sound + 77).toInt();
    print("${sound}db");
    if(Sound > 0 && !_oversound &&_isAuto){
      //oversoundをTrueにすることで生成してすぐに消すコードをとめるようにする
      _oversound=true;

    }
    if(Sound > _Maxsound){
      _Maxsound=Sound;
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
      Autofilename="${now.year},${now.month},${now.day},${now.hour},${now.minute},${now.second}";
      final localFile = '${pathToWrite}/Auto/${Autofilename}.m4a';

      // 録音開始
      await record.start(config, path: localFile);
      LatestCreatefile=localFile;

    }
  }
  Future<void> Autodeletefile() async {
    if(_oversound){
      print("$AutofilesをAutodeleteflie（）で閲覧");
      _Createdbfile(true);
      setState(() {});
    }else{
      final file = File(LatestCreatefile);

      if (await file.exists()&&_Maxsound!=0) {
        await file.delete();
        print("$fileをAutodeletefile()で消したよ");
      }else if(_Maxsound==0){
        print("_MAxsoundが０です");
      }
      else{
        print("ファイルが存在しないぞ");
        print(file);
      }
    }
    _Maxsound=0;
  }
  // 録音停止
  void _AutostopRecording() async {
    await record.stop();

    AutoappDocDir = await getApplicationDocumentsDirectory();
    final recordingFolderPath = '${AutoappDocDir.path}/Auto';
    final recordingDirectory = Directory(recordingFolderPath);
    //judge(false);
    setState(() {
      // ディレクトリ内のファイルリストを取得
      _Setfiles();
    });

    print("自動録音${Autofiles.length}");
  }
  // 自動録音の開始停止
  Future<void> _AutorecordingHandle() async {
    // 再生中の場合は何もしない
    if (_playingStatus) {return;}
    bool escape = false;
    int n=0;
    _AutorecordingStatus = !_AutorecordingStatus;
    if(!_AutorecordingStatus){
      escape=true;
      _AutostopRecording();
      Autodeletefile();

    }
    while(_AutorecordingStatus){
      _AutostartRecording();
      await Future.delayed(Duration(seconds: 10));
      if(!escape){
        judge(true,true);
        Autodeletefile();
        _AutostopRecording();
        judge(false,true);
        n++;
        print("$escapeこれエスケープで$_AutorecordingStatusこれがステータス");
        print("今${n}回");
      }

    }

  }
  Future<void> _Createdbfile(_isAuto) async {
    var dbFolderPath = "";
    //ここからは最大DBを保存するコード。ファイルの中の順番が新しいファイルが上にくるようにdbNumで調整する。
    if(_isAuto){
      dbFolderPath = '${directory.path}/Autodb';
    }else{
      dbFolderPath = '${directory.path}/db';
    }
    final dbDirectory = Directory(dbFolderPath);
    final dbPaths = dbDirectory.listSync();
    DateTime now = DateTime.now();
    final txtfile = File('$dbFolderPath/$now,$_Maxsound');
    if (!await txtfile.exists()) {
    await txtfile.create();
    }
    print("$dbPathsこれはdbのパス一蘭");
    setState(() {_Setfiles();});
  }
  //リストからファイル削除
  void _deleteFile(String filename,_isAuto) async {
    // Get the index of the file in the list
    int index=0;
    if(_isAuto){
      index = Autofiles.indexWhere((file) => basename(file.path) == filename);
      Autofiles.removeAt(index);
    }else{
      index = files.indexWhere((file) => basename(file.path) == filename);
      files.removeAt(index);
    }
    // Remove the file from the list


    // Remove the file from the file system
    late File file;
    if(_isAuto){
      file = File('${directory.path}/Auto/$filename');
    }else{
      file = File('${directory.path}/recording/$filename');
    }

    if (await file.exists()) {
      await file.delete();

      print("$fileをdeletefile()で消したよ");
    }else{
      print("$fileはdeletefile()できえてないよ");
    }
    // Remove the entry from the map
    _playingStatusMap.remove(filename);

    setState(() {_Setfiles();});
  }

  //ファイルのセッティング
  void _Setfiles() async {
    List<String> itizilist =[];
    final recordingFolderPath = '${directory.path}/recording';
    final recordingDirectory = Directory(recordingFolderPath);
    files = recordingDirectory.listSync();
    // 各ファイル名に対してマップにエントリーを追加
    for (var file in files) {
      String fileName = basename(file.path);
      itizilist.add(fileName);
      _playingStatusMap[fileName] = false;
    }

    final AutorecordingFolderPath = '${directory.path}/Auto';
    final AutorecordingDirectory = Directory(AutorecordingFolderPath);
    Autofiles = AutorecordingDirectory.listSync();
    for (var file in Autofiles) {
      String fileName = basename(file.path);
      _playingStatusMap[fileName] = false;
    }
    print("履歴画面${files.length}");
    final historyFolderPath = '${directory.path}/history';
    final historyDirectory = Directory(historyFolderPath);
    final historypaths = historyDirectory.listSync();
     itizilist =[];
    for (var file in historypaths) {
      String fileName = basename(file.path);
      itizilist.add(fileName);
    }
    history = itizilist;
    final  AutodbFolderPath = '${directory.path}/Autodb';
    final AutodbDirectory = Directory(AutodbFolderPath);
    final AutodbPaths = AutodbDirectory.listSync();
    itizilist =[];
    for (var file in AutodbPaths) {
      String fileName = basename(file.path);
      itizilist.add(fileName);
    }
    AutodbList = itizilist;
    final dbFolderPath = '${directory.path}/db';
    final dbDirectory = Directory(dbFolderPath);
    final dbPaths = dbDirectory.listSync();
    itizilist =[];
    for (var file in dbPaths) {
      String fileName = basename(file.path);
      itizilist.add(fileName);
    }
    dbList = itizilist;
    // ウィジェットを再描画
    setState(() {});
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

    print("$historyはsaveDateTime()で作ったよ");

    setState(() {_Setfiles();});
  }
  Future<void> Deletedbfile(index,isAuto) async {
    // DBフォルダのリストを作ってそこからindex番目のものを消す
    var dbFolderPath = '';
    if(isAuto){
      dbFolderPath = '${directory.path}/Autodb';
    }else{
      dbFolderPath = '${directory.path}/db';
    }
    final dbDirectory = Directory(dbFolderPath);
    final dbPaths = dbDirectory.listSync();
    List<String> itizilist =[];
    for (var file in dbPaths) {
      String fileName = basename(file.path);
      itizilist.add(fileName);
    }
    String dbFilename="";
    if(isAuto){
      AutodbList = itizilist;
      dbFilename=AutodbList[index] ;
    }else{
      dbList = itizilist;
      dbFilename=dbList[index];
    }

    final dbfile = File('$dbFolderPath/$dbFilename');
    if (await dbfile.exists()) {
      await dbfile.delete();
      print("$dbfileはDeletedbfile()で消したよ");
    }
    setState(() {_Setfiles();});
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
      print("$fileはDeleteDateTime()で消したよ");
    }

    setState(() {_Setfiles();});
  }
  // 再生開始
  void _startPlaying(String filename,_isAuto) async {

    // 再生するファイルを指定
    final localFile ;
    String pathToWrite = directory.path;
    if(_isAuto){
      localFile = '$pathToWrite/Auto/$filename';
    }else{
      localFile = '$pathToWrite/recording/$filename';
    }


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
  void _playingHandle(String filename,_isAuto) {
    print(filename);
    setState(() {
      // 録音中の場合は録音停止
      if (_recordingStatus) {
        _recordingStatus = false;
      }
      // 再生中の場合は停止、停止中の場合は再生
      _playingStatusMap[filename] = !_playingStatusMap[filename]!;

      if (_playingStatusMap[filename]!) {
        _startPlaying(filename,_isAuto);
      } else {
        _pausePlaying();
      }
    });
  }

  void _startTimer(bool IsAuto) {

    setState(() {
      if(IsAuto){
        _isAutoStart=!_isAutoStart;
      }else{
        _isStart = !_isStart;
      }

      if (_isStart || _isAutoStart) {
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
  //再生中に表示するウィジェット
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
  var _isStart = false;
  var _isAutoStart = false;
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

          Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isAutoStart ? Colors.greenAccent.withOpacity(0.5) : Colors.greenAccent,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: _isAutoStart
                      ? null // _isStartがtrueのときはnullを指定してボタンが押せなくなります
                      : () async {
                    _startTimer(false);
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
              SizedBox(width: 32), // ボタン間のスペースを設けるための間隔
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isStart ? Colors.red.withOpacity(0.5) : Colors.red, // 別の色を使用する例
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: _isStart
                      ? null // _isStartがtrueのときはnullを指定してボタンが押せなくなります
                      : () async {
                    _startTimer(true);
                    _AutorecordingHandle();
                  },
                  child: Center(
                    child: Text(
                      _isAutoStart ? '停止' : '開始',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
              // 他にも必要なボタンがあれば同様に追加
            ],
          ),
          SizedBox(height: 20),

        Container(
          child: Text("自動録音のリスト"),
        ),
        Flexible(
           child: Container(
              child:ListView.builder(
                      physics: ClampingScrollPhysics(),
                      itemCount: Autofiles.length,
                      itemBuilder: (context, index) {
                        String dB = index < AutodbList.length ? AutodbList[index] : 'Null';
                        if(dB!="Null"){
                          List<String> parts = AutodbList[index].split(',');
                          dB=parts[1];
                        }
                        String fileName = index < Autofiles.length
                            ? basename(Autofiles[Autofiles.length - index - 1].path)
                            : '自動録音のファイルが存在しません';
                        return Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 20.0),
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
                                        _playingHandle(fileName,true);
                                      },

                                      style: ElevatedButton.styleFrom(
                                        shape: const CircleBorder(),
                                        primary: Colors.transparent,
                                        // ボタンの背景を透明にする
                                        elevation: 0, // ボタンの影を削除
                                      ),

                                      child: _playingStatusMap[fileName] ??
                                          false
                                          ? const Icon(
                                          Icons.stop, color: Colors.grey)
                                          : const Icon(
                                          Icons.play_arrow, color: Colors.grey),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        _deleteFile(fileName,true);
                                        Deletedbfile(index,true);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: const CircleBorder(),
                                        primary: Colors.transparent, // 透明な背景色
                                        elevation: 0, // ボタンの影を削除
                                      ),
                                      child: const Icon(
                                          Icons.delete, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),),),
          Container(
            child: Text("録音のリスト"),
          ),
        Flexible(
            child: Container(
                child:ListView.builder(
                      physics: ClampingScrollPhysics(),
                      itemCount: files.length,
                      itemBuilder: (context, index) {
                        String dB = index < dbList.length ? dbList[index] : 'Null';
                        if(dB!="Null"){
                          List<String> parts = dbList[index].split(',');
                          dB=parts[1];
                        }
                        String fileName = index < files.length
                            ? basename(files[files.length - index - 1].path)
                            : 'Miss file';
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
                                        _playingHandle(fileName,false);
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
                                        _deleteFile(fileName,false);
                                        Deletedbfile(index,false);                                      },
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
            ),),

          _buildPlaybackWidget(), // ここで再生中のウィジェットを表示
        ],
      ),
      bottomNavigationBar:Footer(currentIndex: 0,context: context),
    );
  }

}