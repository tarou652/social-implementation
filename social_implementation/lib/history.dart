import 'dart:io';
import 'package:SI/components/fotter.dart';
import 'package:SI/components/header.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(HistoryPage());
}

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Internal Storage Files List',
      home: Scaffold(
        appBar: AppBar(title: Text('Internal Storage Files List')),
        body: FilesListWidget(),
      ),
    );
  }
}

class FilesListWidget extends StatefulWidget {
  @override
  _FilesListWidgetState createState() => _FilesListWidgetState();
}

class _FilesListWidgetState extends State<FilesListWidget> {
  List<String> _fileList = [];

  @override
  void initState() {
    super.initState();
    _listInternalFiles(); // 内部ストレージのファイルをリスト化する処理を呼び出す
  }

  Future<void> _listInternalFiles() async {
    try {
      Directory appDir =
          await getApplicationDocumentsDirectory(); // 内部ストレージのディレクトリパスを取得
      List<FileSystemEntity> files = appDir.listSync(); // ディレクトリ内のファイル一覧を取得
      setState(() {
        _fileList = files.map((file) => file.path).toList(); // ファイルのパスをリストに追加
      });
    } catch (e) {
      print('Error listing internal files: $e'); // ファイルリスト作成中にエラーが発生したことを表示
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(text: "Internal Storage Files List"),
      body: ListView.separated(
        itemCount: _fileList.length,
        separatorBuilder: (context, index) => Divider(), // ファイルごとに区切り線を挿入
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_fileList[index]), // ファイルのパスを表示
          );
        },
      ),
      bottomNavigationBar: Footer(currentIndex: 2, context: context),
    );
  }
}

class Header extends StatelessWidget implements PreferredSizeWidget {
  final String text;

  const Header({Key? key, required this.text}) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(text),
    );
  }
}

class Footer extends StatelessWidget {
  final int currentIndex;
  final BuildContext context;

  const Footer({Key? key, required this.currentIndex, required this.context})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.business),
          label: 'Business',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'History',
        ),
      ],
      onTap: (index) {
        // Handle item taps here
      },
    );
  }
}
